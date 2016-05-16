//
//  AMP2PViewController.m
//  Artsmesh
//
//  Created by Whisky Zed on 163/24/.
//  Copyright © 2016年 Artsmesh. All rights reserved.
//

#import "AMP2PViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import "AMVideoDeviceManager.h"
#import "AMSyphonView.h"
#import <VideoToolbox/VideoToolbox.h>
#import "AMNetworkUtils/JSONKit.h"
#import "AMNetworkUtils/GCDAsyncUdpSocket.h"


#include "AMLogger/AMLogger.h"
#include <stdio.h>      /* standard C i/o facilities */
#include <stdlib.h>     /* needed for atoi() */
#include <unistd.h>     /* defines STDIN_FILENO, system calls,etc */
#include <sys/types.h>  /* system data type definitions */
#include <sys/socket.h> /* socket specific definitions */
#include <netinet/in.h> /* INET constants and stuff */
#include <arpa/inet.h>  /* IP address conversion stuff */
#include <netdb.h>      /* gethostbyname */
#include "VideoView.h"

#define MAXBUF 1024*1024

NSString *const AMP2PVideoReceiverChanged;

NSString *const naluTypesStrings[] =
{
    @"0: Unspecified (non-VCL)",
    @"1: Coded slice of a non-IDR picture (VCL)",    // P frame
    @"2: Coded slice data partition A (VCL)",
    @"3: Coded slice data partition B (VCL)",
    @"4: Coded slice data partition C (VCL)",
    @"5: Coded slice of an IDR picture (VCL)",      // I frame
    @"6: Supplemental enhancement information (SEI) (non-VCL)",
    @"7: Sequence parameter set (non-VCL)",         // SPS parameter
    @"8: Picture parameter set (non-VCL)",          // PPS parameter
    @"9: Access unit delimiter (non-VCL)",
    @"10: End of sequence (non-VCL)",
    @"11: End of stream (non-VCL)",
    @"12: Filler data (non-VCL)",
    @"13: Sequence parameter set extension (non-VCL)",
    @"14: Prefix NAL unit (non-VCL)",
    @"15: Subset sequence parameter set (non-VCL)",
    @"16: Reserved (non-VCL)",
    @"17: Reserved (non-VCL)",
    @"18: Reserved (non-VCL)",
    @"19: Coded slice of an auxiliary coded picture without partitioning (non-VCL)",
    @"20: Coded slice extension (non-VCL)",
    @"21: Coded slice extension for depth view components (non-VCL)",
    @"22: Reserved (non-VCL)",
    @"23: Reserved (non-VCL)",
    @"24: STAP-A Single-time aggregation packet (non-VCL)",
    @"25: STAP-B Single-time aggregation packet (non-VCL)",
    @"26: MTAP16 Multi-time aggregation packet (non-VCL)",
    @"27: MTAP24 Multi-time aggregation packet (non-VCL)",
    @"28: FU-A Fragmentation unit (non-VCL)",
    @"29: FU-B Fragmentation unit (non-VCL)",
    @"30: Unspecified (non-VCL)",
    @"31: Unspecified (non-VCL)",
};

typedef enum {
    NALUTypeSliceNoneIDR = 1,
    NALUTypeSliceIDR = 5,
    NALUTypeSPS = 7,
    NALUTypePPS = 8
} NALUType;

@interface AMP2PViewController ()
@property (weak) IBOutlet VideoView *videoView;

@property (nonatomic, strong) NSData * spsData;
@property (nonatomic, strong) NSData * ppsData;
@property (nonatomic) CMVideoFormatDescriptionRef videoFormatDescr;
@property (nonatomic) BOOL videoFormatDescriptionAvailable;

@property (nonatomic, retain) IBOutlet NSView* glView;
//@property (weak) IBOutlet AVPlayerView* playerView;
@property (weak) IBOutlet NSPopUpButtonCell *serverTitlePopUpButton;
@property (nonatomic, retain) AVSampleBufferDisplayLayer *avsbDisplayLayer;
@end

@implementation AMP2PViewController
{
    GCDAsyncUdpSocket*              _udpSocket;
    CMVideoFormatDescriptionRef     _formatDesc;
    int                             _index;
    int                             _fileIndex;
    int                             _udpIndex;
    NSMutableData*                  _lastNALUData;
}

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



//Tmp ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (int)getNALUType:(NSData *)NALU {
    uint8_t * bytes = (uint8_t *) NALU.bytes;
    return bytes[0] & 0x1F;
}



- (void)handleSlice:(NSData *)NALU {
    if (self.videoFormatDescriptionAvailable) {
        /* The length of the NALU in big endian */
        const uint32_t NALUlengthInBigEndian = CFSwapInt32HostToBig((uint32_t) NALU.length);
        
        /* Create the slice */
        NSMutableData * slice = [[NSMutableData alloc] initWithBytes:&NALUlengthInBigEndian length:4];
        
        /* Append the contents of the NALU */
        [slice appendData:NALU];
        
        /* Create the video block */
        CMBlockBufferRef videoBlock = NULL;
        
        OSStatus status;
        
        status = CMBlockBufferCreateWithMemoryBlock(NULL, (void*)slice.bytes, slice.length,
                                                    kCFAllocatorNull, NULL, 0, slice.length,
                                                    0, &videoBlock);
        
        NSLog(@"BlockBufferCreation: %@", (status == kCMBlockBufferNoErr) ? @"success" : @"fail");
        
        /* Create the CMSampleBuffer */
        CMSampleBufferRef sbRef = NULL;
        
        const size_t sampleSizeArray[] = { slice.length };
        
        status = CMSampleBufferCreate(kCFAllocatorDefault, videoBlock, true, NULL, NULL,
                                      _videoFormatDescr, 1, 0, NULL, 1, sampleSizeArray, &sbRef);
        
        NSLog(@"SampleBufferCreate: %@", (status == noErr) ? @"success" : @"failed");
        
        /* Enqueue the CMSampleBuffer in the AVSampleBufferDisplayLayer */
        CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sbRef, YES);
        CFMutableDictionaryRef dict = (CFMutableDictionaryRef)CFArrayGetValueAtIndex(attachments, 0);
        CFDictionarySetValue(dict, kCMSampleAttachmentKey_DisplayImmediately, kCFBooleanTrue);
        
        NSLog(@"Error: %@, Status: %@",
              self.videoView.videoLayer.error,
              (self.videoView.videoLayer.status == AVQueuedSampleBufferRenderingStatusUnknown)
              ? @"unknown"
              : (
                 (self.videoView.videoLayer.status == AVQueuedSampleBufferRenderingStatusRendering)
                 ? @"rendering"
                 :@"failed"
                 )
              );
        
        dispatch_async(dispatch_get_main_queue(),^{
            if([self.videoView.videoLayer isReadyForMoreMediaData]){
                [self.videoView.videoLayer enqueueSampleBuffer:sbRef];
                [self.videoView.videoLayer setNeedsDisplay];
            }
        });
    }
}




- (void)handleSPS:(NSData *)NALU {
    _spsData = [NALU copy];
}

- (void)handlePPS:(NSData *)NALU {
    _ppsData = [NALU copy];
}

- (void)updateFormatDescriptionIfPossible {
    if (_spsData != nil && _ppsData != nil) {
        const uint8_t * const parameterSetPointers[2] = {
            (const uint8_t *) _spsData.bytes,
            (const uint8_t *) _ppsData.bytes
        };
        
        const size_t parameterSetSizes[2] = {
            _spsData.length,
            _ppsData.length
        };
        
        OSStatus status = CMVideoFormatDescriptionCreateFromH264ParameterSets(kCFAllocatorDefault, 2,
         parameterSetPointers, parameterSetSizes, 4, &_videoFormatDescr);
        
        _videoFormatDescriptionAvailable = YES;
        
        NSLog(@"Updated CMVideoFormatDescription %@.", (status == noErr) ? @"success" : @"fail");
    }
}

- (void)parseNALU:(NSData *)NALU {
    int type = [self getNALUType: NALU];
    
    NSLog(@"NALU with Type \"%@\" received.", naluTypesStrings[type]);
    
    switch (type)
    {
        case NALUTypeSliceNoneIDR:
        case NALUTypeSliceIDR:
            [self handleSlice:NALU];
            break;
        case NALUTypeSPS:
            [self handleSPS:NALU];
            [self updateFormatDescriptionIfPossible];
            break;
        case NALUTypePPS:
            [self handlePPS:NALU];
            [self updateFormatDescriptionIfPossible];
            break;
        default:
            break;
    }
}



- (IBAction)serverSelected:(NSPopUpButton*)sender {
    NSError *error = nil;
    int port = 0;
    NSString* url = sender.selectedItem.title;
    NSUInteger commaPosition =[url rangeOfString:@":"].location;
    if(commaPosition != NSNotFound){
        NSString* strPort = [url substringFromIndex:commaPosition+1];
        port =[strPort integerValue];
    }
    if(port <= 0){
        AMLog(kAMErrorLog, @"Video Mixer", @"Parse port error");
        return;
    }
    
    _udpSocket = [[GCDAsyncUdpSocket alloc]
                  initWithDelegate:self
                  delegateQueue:dispatch_get_main_queue()];
   
    if (![_udpSocket bindToPort:port error:&error])
    {
        AMLog(kAMErrorLog, @"Video Mixer", @"Create udp socket failed in the port[%d].Error:%@",
                                   port, error);
        return;
    }
    
    if (![_udpSocket beginReceiving:&error])
    {
        [_udpSocket close];
        AMLog(kAMErrorLog, @"Video Mixer", @"Listening socket port failed. Error:%@", error);
        return;
    }
  
    return;
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock
   didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{

    UInt8 tmpStartCode[4];
    tmpStartCode[0] = 0x00;
    tmpStartCode[1] = 0x00;
    tmpStartCode[2] = 0x00;
    tmpStartCode[3] = 0x01;
    int tmpStartCodeLen = 4;
    
    NSData* startCode = [NSData dataWithBytes:&tmpStartCode length:tmpStartCodeLen];

    NSData* recvData = data;
    const char* bufin = (const char*)[recvData bytes];
    
    NSRange prevRange = NSMakeRange(NSNotFound, 0);
    NSRange nextRange = [recvData rangeOfData:startCode
                                      options:0
                                        range:NSMakeRange(0, [recvData length])];
    
    /*
    //~~~~
    if(_udpIndex <= 300){
        NSString* nalFilePath = [NSString stringWithFormat:@"udp_%d",_udpIndex++];
        [fileManager createFileAtPath:nalFilePath
                             contents:recvData
                           attributes:nil];
    }
    //~~~~*/
        
        
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
            
            if([_lastNALUData length] > 0){
            //~~~~~~~
               /* if(_fileIndex <= 300){
                    NSString* nalFilePath = [NSString stringWithFormat:@"nal_%d",_fileIndex++];
                    [fileManager createFileAtPath:nalFilePath
                                         contents:_lastNALUData
                                       attributes:nil];
                }
                */
                
                uint8_t* nh = (uint8_t*)[_lastNALUData bytes] + 4;
                NSData* noheader = [[NSData alloc ] initWithBytes:nh length:[_lastNALUData length] -4];
                
                [self parseNALU:noheader];
            //~~~~~~~
                
                //[self receivedRawVideoFrame:(uint8_t*)_lastNALUData.bytes
                //                   withSize:[_lastNALUData length]];
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
    
    /*
    NSBundle * mainBundle = [NSBundle mainBundle];
    if(_index < 1000) {
        NSString * resource = [NSString stringWithFormat:@"nalu_%03d", _index];
        NSString * path = [mainBundle pathForResource:resource ofType:@"bin"];
        NSData * NALU = [NSData dataWithContentsOfFile:path];
        [self parseNALU:NALU];
        
        _index = (_index + 1) % 1000;
    }
    return;
    */
}



-(void) observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context{
    if ([keyPath isEqualToString:@"status"]){
//        [_player play];
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self updateServerTitle];
    NSNotificationCenter* defaultNC = [NSNotificationCenter defaultCenter];
    [defaultNC addObserver:self
                  selector:@selector(updateServerTitle)
                      name:AMP2PVideoReceiverChanged
                    object:nil];
    _lastNALUData = [[NSMutableData alloc] init];
}




-(void) updateServerTitle
{
    [_serverTitlePopUpButton removeAllItems];
    
    NSArray* serverTitles = [self getP2PServerNames];
    [_serverTitlePopUpButton addItemsWithTitles:serverTitles];
}

-(NSArray*)getP2PServerNames
{
    NSMutableArray*         serverNames   = [[NSMutableArray alloc] init];
    AMVideoDeviceManager*   deviceManager = [AMVideoDeviceManager sharedInstance];

    for (AMVideoDevice* device in [deviceManager allServerDevices]) {
        NSString* serverTitle = device.deviceID;
        [serverNames addObject:serverTitle];
    }
        
    return serverNames;
}
 

//First, add the base of the function which deals with H.264 from the network
-(void) receivedRawVideoFrame:(uint8_t *)frame withSize:(NSUInteger)frameSize
{
    return;
    OSStatus status;
    
    uint8_t *data = NULL;
   
    long blockLength = 0;
    CMSampleBufferRef   sampleBuffer;
    CMBlockBufferRef    blockBuffer;
    
    int nalu_type = (frame[4] & 0x1F);
    NSLog(@"~~~~~~~ Received NALU Type \"%@\" ~~~~~~~~", naluTypesStrings[nalu_type]);
    
    // if we havent already set up our format description with our SPS PPS parameters, we
    // can't process any frames except type 7 that has our parameters
    /*if (nalu_type != 7 && _formatDesc == NULL)
    {
        NSLog(@"Video error: Frame is not an I Frame and format description is null");
        return;
    }*/
    
    if (nalu_type == 7 || nalu_type == 8)
    {
        // find what the second NALU type is
        nalu_type = (frame[4] & 0x1F);
        NSLog(@"~~~~~~~ Received NALU Type \"%@\" ~~~~~~~~", naluTypesStrings[nalu_type]);
        
        if(nalu_type == 7){
            _spsData = [[NSData alloc] initWithBytes:frame+4  length:frameSize-4];
//            _spsSize = frameSize - 4;
        }
        else{
            _ppsData = [[NSData alloc] initWithBytes:frame+4  length:frameSize-4];
//            _ppsSize = frameSize - 4;
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
            if(status != noErr) NSLog(@"\t Format Description ERROR type: %d", (int)status);
        }
    }
    if(nalu_type == 5 || nalu_type == 1)
    { // type 5 is an IDR frame NALU.  The SPS and PPS NALUs should always be followed by an IDR
        if(nalu_type == 5)
        {
            blockLength = frameSize;
            data = malloc(blockLength);
            memcpy(data, frame, blockLength);
        
            // replace the start code header on this NALU with its size, which AVCC format requires.
            // htonl converts the unsigned int from host to network byte order
            
            uint32_t dataLength32 = htonl (blockLength - 4);
            memcpy (data, &dataLength32, sizeof (uint32_t));
        
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
            blockLength = frameSize;
            data = malloc(blockLength);
            memcpy(data, frame, blockLength);
        
            // again, replace the start header with the size of the NALU
            uint32_t dataLength32 = htonl (blockLength - 4);
            memcpy (data, &dataLength32, sizeof (uint32_t));
        
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
        
            //send the samplebuffer to an AVSampleBufferDisplayLayer
            NSLog(@"Error: %@, Status: %@",
                  _avsbDisplayLayer.error,
                  (_avsbDisplayLayer.status == AVQueuedSampleBufferRenderingStatusUnknown)
                  ? @"unknown"
                  : (
                     (_avsbDisplayLayer.status == AVQueuedSampleBufferRenderingStatusRendering)
                     ? @"rendering"
                     :@"failed"
                     )
                  );
            
            dispatch_async(dispatch_get_main_queue(),^{
                [self.videoView.videoLayer enqueueSampleBuffer:sampleBuffer];
                [self.videoView.videoLayer setNeedsDisplay];
            });
        }
    
        // free memory to avoid a memory leak, do the same for sps, pps and blockbuffer
        if (NULL != data)
        {
            free (data);
            data = NULL;
        }
    }
}




@end
