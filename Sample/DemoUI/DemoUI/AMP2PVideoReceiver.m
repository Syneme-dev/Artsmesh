//
//  AMP2PVideoReceiver.m
//  Artsmesh
//
//  Created by Whisky Zed on 167/15/.
//  Copyright © 2016年 Artsmesh. All rights reserved.
//

#import "AMP2PVideoReceiver.h"
#import <Cocoa/Cocoa.h>
#import <VideoToolbox/VideoToolbox.h>
#import "AMNetworkUtils/GCDAsyncUdpSocket.h"
//#import "AMP2PVideoView.h"
#import "AMP2PVideoCommon.h"

@interface AMP2PVideoReceiver ()
@property (strong, nonatomic) NSMutableData*  lastNALUData;
@property (nonatomic, retain) AVSampleBufferDisplayLayer* videoLayer;
@property (nonatomic, strong) NSData * spsData;
@property (nonatomic, strong) NSData * ppsData;
@property (nonatomic) CMVideoFormatDescriptionRef videoFormatDescr;
@property (nonatomic, retain) AVSampleBufferDisplayLayer *avsbDisplayLayer;
@end


@implementation AMP2PVideoReceiver
{
    GCDAsyncUdpSocket*              _udpSocket;
    CMVideoFormatDescriptionRef     _formatDesc;
    NSMutableData*                  _lastNALUData;
    BOOL                            _searchForSPSAndPPS;
    BOOL                            _ableToDecodeFrame;
    NSInteger                       _port;
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock
   didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    if(_lastNALUData == nil){
        _lastNALUData = [[NSMutableData alloc] init];
    }
    
    
    UInt8 tmpStartCode[3];
    tmpStartCode[0] = 0x00;
    tmpStartCode[1] = 0x00;
    tmpStartCode[2] = 0x01;
    int scLen = 3;
    
    NSData* startCode = [NSData dataWithBytes:&tmpStartCode length:scLen];
    
    NSData* recvData = data;
    const char* bufin = (const char*)[recvData bytes];
    
    NSRange prevRange = NSMakeRange(NSNotFound, 0);
    NSRange nextRange = [recvData rangeOfData:startCode
                                      options:0
                                        range:NSMakeRange(0, [recvData length])];
    
    
    
    if(nextRange.location != NSNotFound){
        while(nextRange.location != NSNotFound) {
            if(prevRange.location == NSNotFound){ //first time find the start code.){
                prevRange.location = 0;
                if((nextRange.location - prevRange.location) > 0){
                    [_lastNALUData appendBytes:(uint8_t*)recvData.bytes + prevRange.location
                                        length:nextRange.location - prevRange.location];
                }
            }else{// Multiple times find start code in a single udp packet.
                _lastNALUData = [[NSMutableData alloc]
                                 initWithBytes:bufin+prevRange.location
                                 length:nextRange.location - prevRange.location];
            }
            
            if([_lastNALUData length] > 3){
                int startCodeAppendLen = 0;
                uint8_t* dataBytes = (uint8_t*)[_lastNALUData bytes];
                if( dataBytes[[_lastNALUData length] - 1] == 0){
                    startCodeAppendLen = 1;
                }
                
                [self receivedRawVideoFrame:(uint8_t*)[_lastNALUData bytes]
                                   withSize:[_lastNALUData length] - startCodeAppendLen];
            }
            
            prevRange = nextRange;
            nextRange = [recvData rangeOfData:startCode
                                      options:0
                                        range:NSMakeRange(prevRange.location+[startCode length],
                                                          [recvData length]-prevRange.location-[startCode length])];
        }
        
        //When find no other start code, just store the rest.
        _lastNALUData = [[NSMutableData alloc]
                         initWithBytes:bufin + prevRange.location
                         length:[recvData length] - prevRange.location];
    }else{ //Not found
        [_lastNALUData appendData:recvData];
    }
}
-(void) receivedRawVideoFrame:(uint8_t *)frame withSize:(NSUInteger)frameSize
{
    OSStatus  status;
    uint8_t*  data = NULL;
    
    long blockLength = 0;
    CMSampleBufferRef   sampleBuffer;
    CMBlockBufferRef    blockBuffer;
    
    int nalu_type = (frame[3] & 0x1F);
    NSLog(@"~~~~~~~ Received NALU Type \"%@\" ~~~~~~~~", naluTypesStrings[nalu_type]);
    
    if (nalu_type == 7 || nalu_type == 8)
    {
        // find what the second NALU type is
        nalu_type = (frame[3] & 0x1F);
        NSLog(@"~~~~~~~ Received NALU Type \"%@\" ~~~~~~~~", naluTypesStrings[nalu_type]);
        
        if(nalu_type == 7){
            _spsData = [[NSData alloc] initWithBytes:frame+3  length:frameSize-3];
        }
        else{
            _ppsData = [[NSData alloc] initWithBytes:frame+3  length:frameSize-3];
        }
        
        // now we set our H264 parameters
        if (_spsData != nil && _ppsData != nil) {
            const uint8_t * const parameterSetPointers[2] = {
                (const uint8_t *) _spsData.bytes,
                (const uint8_t *) _ppsData.bytes
            };
            
            const size_t parameterSetSizes[2] = {
                _spsData.length,
                _ppsData.length
            };
            
            CMVideoFormatDescriptionRef videoFormatDescr;
            status = CMVideoFormatDescriptionCreateFromH264ParameterSets(kCFAllocatorDefault, 2,
                                                                         (const uint8_t *const*)parameterSetPointers,
                                                                         parameterSetSizes, 4,
                                                                         &videoFormatDescr);
            _formatDesc = videoFormatDescr;
            NSLog(@"\t Update CMVideoFormatDescription:%@", (status == noErr) ? @"success" : @"fail");
            
            if(status != noErr){
                NSLog(@"\t Format Description ERROR type: %d", (int)status);
            }else{
                _ableToDecodeFrame = TRUE;
            }
        }
    }
    
    if(_ableToDecodeFrame && ( nalu_type == 5 || nalu_type == 1))
    {
        // type 5 is an IDR frame NALU.  The SPS and PPS NALUs should always be followed by an IDR
        blockLength = frameSize+1;
        data = malloc(blockLength);
        memcpy(data+1, frame, blockLength-1);
        
        // again, replace the start header with the size of the NALU
        uint32_t dataLength32 = CFSwapInt32HostToBig(blockLength-4);
        memcpy (data, &dataLength32, sizeof (uint32_t));
        
        if(nalu_type == 5)
        {
            // create a block buffer from the IDR NALU
            status = CMBlockBufferCreateWithMemoryBlock(NULL, data,  // memoryBlock to hold buffered data
                                                        blockLength,
                                                        kCFAllocatorNull, NULL,
                                                        0, // offsetToData
                                                        blockLength,   // dataLength of relevant bytes, starting at offsetToData
                                                        0, &blockBuffer);
            
            NSLog(@"\t BlockBufferCreation:%@", (status == kCMBlockBufferNoErr)?@"success" : @"fail");
        }
        
        // NALU type 1 is non-IDR (or PFrame) picture
        if (nalu_type == 1)
        {
            // non-IDR frames do not have an offset due to SPS and PSS, so the approach
            // is similar to the IDR frames just without the offset
            
            status = CMBlockBufferCreateWithMemoryBlock(NULL, data,
                                                        blockLength,
                                                        kCFAllocatorNull, NULL,
                                                        0,     // offsetToData
                                                        blockLength,
                                                        0, &blockBuffer);
            
            NSLog(@"\t BlockBufferCreation:%@", (status == kCMBlockBufferNoErr) ? @"success" : @"fail");
        }
        
        // now create our sample buffer from the block buffer,
        if(status == noErr)
        {
            // Don't bother with timing specifics since now we just display all frames immediately
            const size_t sampleSize = blockLength;
            status = CMSampleBufferCreate(kCFAllocatorDefault,
                                          blockBuffer, true, NULL, NULL,
                                          _formatDesc, 1, 0, NULL, 1,
                                          &sampleSize, &sampleBuffer);
            
            NSLog(@"\t SampleBufferCreate:%@", (status == noErr) ? @"success" : @"fail");
        }
        
        if(status == noErr)
        {
            // set some values of the sample buffer's attachments
            CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, YES);
            CFMutableDictionaryRef dict = (CFMutableDictionaryRef)CFArrayGetValueAtIndex(attachments, 0);
            CFDictionarySetValue(dict, kCMSampleAttachmentKey_DisplayImmediately, kCFBooleanTrue);
            
            NSLog(@"Error: %@, Status: %@",
                  self.videoLayer.error,
                  (self.videoLayer.status == AVQueuedSampleBufferRenderingStatusUnknown)
                  ? @"unknown"
                  : (
                     (self.videoLayer.status == AVQueuedSampleBufferRenderingStatusRendering)
                     ? @"rendering"
                     :@"failed"
                     )
                  );
            
            dispatch_async(dispatch_get_main_queue(),^{
                if([self.videoLayer isReadyForMoreMediaData]){
                    [self.videoLayer enqueueSampleBuffer:sampleBuffer];
                    [self.videoLayer setNeedsDisplay];
                }
            });
        }
    }
}


@end
