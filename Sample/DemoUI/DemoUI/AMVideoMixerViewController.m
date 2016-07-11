//
//  AMVideoMixerViewController.m
//  AMVideo
//
//  Created by robbin on 11/17/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import "AMVideoMixerViewController.h"
#import "AMVideoMixerBackgroundView.h"
#import "AMPanelViewController.h"
#import "UIFrameWork/AMPanelView.h"
#import "AMAppDelegate.h"
#import "AMSyphonView.h"
#import "AMSyphonCamera.h"

#import "AMP2PVideoView.h"
#import "AMP2PVideoCommon.h"
#import <VideoToolbox/VideoToolbox.h>
#import "AMNetworkUtils/JSONKit.h"
#import "AMNetworkUtils/GCDAsyncUdpSocket.h"
#include "AMLogger/AMLogger.h"

@interface AMVideoMixerViewController ()
@property (weak) IBOutlet AMVideoMixerBackgroundView *bigView;
@property (weak) IBOutlet AMVideoMixerBackgroundView *smallView0;
@property (weak) IBOutlet AMVideoMixerBackgroundView *smallView1;
@property (weak) IBOutlet AMVideoMixerBackgroundView *smallView2;
@property (weak) IBOutlet AMVideoMixerBackgroundView *smallView3;
@property (weak) IBOutlet AMVideoMixerBackgroundView *smallView4;
@property (weak) IBOutlet AMVideoMixerBackgroundView *smallView5;
@property (weak) IBOutlet AMVideoMixerBackgroundView *smallView6;
@property (weak) IBOutlet AMVideoMixerBackgroundView *smallView7;
@property (weak) IBOutlet AMVideoMixerBackgroundView *smallView8;
@property (weak) IBOutlet AMVideoMixerBackgroundView *smallView9;
@property (strong, nonatomic, readonly) NSArray *smallViews;
@property (weak, nonatomic) AMVideoMixerBackgroundView *selected;

@property  (nonatomic) AMSyphonCamera* syCamera;
@end


@interface AMVideoMixerViewController ()
@property (strong, nonatomic) NSMutableData*  lastNALUData;
@property (nonatomic, retain) AMP2PVideoView* videoView;
@property (nonatomic, strong) NSData * spsData;
@property (nonatomic, strong) NSData * ppsData;
@property (nonatomic) CMVideoFormatDescriptionRef videoFormatDescr;
@property (nonatomic, retain) AVSampleBufferDisplayLayer *avsbDisplayLayer;
@end


@implementation AMVideoMixerViewController
{
    GCDAsyncUdpSocket*              _udpSocket;
    CMVideoFormatDescriptionRef     _formatDesc;
    NSMutableData*                  _lastNALUData;
    BOOL                            _searchForSPSAndPPS;
    BOOL                            _ableToDecodeFrame;
    NSInteger                       _port;
}

@synthesize smallViews = _smallViews;

//Temper added for receive and display
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
                    [self.videoView.videoLayer enqueueSampleBuffer:sampleBuffer];
                    [self.videoView.videoLayer setNeedsDisplay];
                }
            });
        }
    }
}


////////////!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
    
    _syCamera = [[AMSyphonCamera alloc] init];
    [_syCamera initializeDevice];
    
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(getP2PInfo:)
               name:AMP2PVideoInfoNotification
             object:nil];

}

-(void) startP2PVideo;
{
    if(_port <= 0)
        return;
    NSError *error = nil;
    /*int port = [notification.userInfo[@"port"] intValue];*/
    _ableToDecodeFrame = FALSE;
    
    _udpSocket = [[GCDAsyncUdpSocket alloc]
                  initWithDelegate:self
                  delegateQueue:dispatch_get_main_queue()];
    
    if (![_udpSocket bindToPort:_port error:&error])
    {
        AMLog(kAMErrorLog, @"Video Mixer", @"Create udp socket failed in the port[%d].Error:%@",
              _port, error);
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

- (void)setup
{
    self.bigView.hasBorder = YES;
    self.bigView.contentView = [self.syphonManager outputView];
    

    for (int i = 0; i < self.smallViews.count/2; i++) {
        AMVideoMixerBackgroundView *view = self.smallViews[i];
        view.contentView = [self.syphonManager clientViewByIndex:i];
    }
    
    for (NSUInteger j = self.smallViews.count / 2; j < self.smallViews.count; j++) {
        AMVideoMixerBackgroundView *view = self.smallViews[j];
        view.contentView = [self.p2pViewManager clientViewByIndex:(j-self.smallViews.count / 2)];
    }
}

- (AMSyphonManager *)syphonManager
{
    if (!_syphonManager) {
        _syphonManager = [[AMSyphonManager alloc] initWithClientCount:(int)self.smallViews.count/2];
    }
    return _syphonManager;
}

- (AMP2PViewManager *)p2pViewManager
{
    if (!_p2pViewManager) {
        _p2pViewManager = [[AMP2PViewManager alloc] initWithClientCount:(int)self.smallViews.count/2];
    }
    return _p2pViewManager;
}



- (NSArray *)smallViews
{
    if (!_smallViews) {
        _smallViews = @[
            self.smallView0,
            self.smallView1,
            self.smallView2,
            self.smallView3,
            self.smallView4,
            self.smallView5,
            self.smallView6,
            self.smallView7,
            self.smallView8,
            self.smallView9
        ];
    }
    return _smallViews;
}

- (IBAction)handleSelectEvent:(AMVideoMixerBackgroundView *)sender
{
    if (sender == self.bigView) {
        if (sender.clickCount == 2) {
            [self popupVideoMixingWindow];
        }
    }else if(sender.clickCount == 2 && (sender == self.smallView5 || sender == self.smallView6 ||
             sender == self.smallView7 || sender == self.smallView8 ||
             sender == self.smallView9)){
        
        //if([self.sender ])
        {
            int index = (int)[self.smallViews indexOfObjectIdenticalTo:self.selected];
            AMP2PViewController* viewCtrl = [self.p2pViewManager clientViewControllerByIndex:(index-5)];
            _port = [viewCtrl stopP2PVideo];
            
            if (_port > 0) {
                [self popupP2PVideoMixingWindow];
                [self startP2PVideo];
            }
            //NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
            //[nc postNotificationName:AMP2PVideoStopNotification object:viewCtrl];
            
            //int port = [viewCtrl ];
        }
    }else {
        if (sender.clickCount == 1 && sender != self.selected) {
            self.selected.hasBorder = NO;
            self.selected = sender;
            self.selected.hasBorder = YES;
            int index = (int)[self.smallViews indexOfObjectIdenticalTo:self.selected];
            [self.syphonManager selectClient:index];
        }
    }
}
-(void) popupP2PVideoMixingWindow
{
    static NSString *panelId = @"AMP2PVideoMixingWindow";
    
    AMAppDelegate *appDelegate = (AMAppDelegate *)[NSApp delegate];
    NSMutableDictionary *panelControllers = appDelegate.mainWindowController.panelControllers;
    
    if (!panelControllers[panelId]) {
        AMPanelViewController *popupController =
        [[AMPanelViewController alloc] initWithNibName:@"AMPanelView" bundle:nil];
        popupController.panelId = panelId;
        panelControllers[panelId] = popupController;
        AMPanelView *panelView = (AMPanelView *)popupController.view;
        panelView.panelViewController = popupController;
        panelView.preferredSize = NSMakeSize(800, 600);
        panelView.initialSize = panelView.preferredSize;
        
        AMP2PVideoView *subview = [[AMP2PVideoView alloc] init];
        self.videoView = subview;
        subview.frame = NSMakeRect(0, 20, panelView.bounds.size.width, panelView.bounds.size.height - 16);
        [subview setTranslatesAutoresizingMaskIntoConstraints:NO];
        [panelView addSubview:subview];
        NSDictionary *views = @{ @"subview" : subview };
        [panelView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subview]|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        [panelView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[subview]-16-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        
        [popupController onTearClick:self];
        popupController.title = @"P2PMIXING";
        popupController.settingButton.hidden = YES;
        popupController.tearOffButton.hidden = YES;
        popupController.tabPanelButton.hidden = YES;
        popupController.maxSizeButton.hidden = YES;
    }

}

- (void)popupVideoMixingWindow
{
    static NSString *panelId = @"AMVideoMixingPopupPanel";
    
    AMAppDelegate *appDelegate = (AMAppDelegate *)[NSApp delegate];
    NSMutableDictionary *panelControllers = appDelegate.mainWindowController.panelControllers;
    
    if (!panelControllers[panelId]) {
        AMPanelViewController *popupController =
            [[AMPanelViewController alloc] initWithNibName:@"AMPanelView" bundle:nil];
        popupController.panelId = panelId;
        panelControllers[panelId] = popupController;
        AMPanelView *panelView = (AMPanelView *)popupController.view;
        panelView.panelViewController = popupController;
        panelView.preferredSize = NSMakeSize(800, 600);
        panelView.initialSize = panelView.preferredSize;
        
        NSView *subview = [self.syphonManager tearOffView];
        subview.frame = NSMakeRect(0, 20, panelView.bounds.size.width, panelView.bounds.size.height - 16);
        [subview setTranslatesAutoresizingMaskIntoConstraints:NO];
        [panelView addSubview:subview];
        NSDictionary *views = @{ @"subview" : subview };
        [panelView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subview]|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        [panelView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[subview]-16-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        
        [popupController onTearClick:self];
        popupController.title = @"MIXING";
        popupController.settingButton.hidden = YES;
        popupController.tearOffButton.hidden = YES;
        popupController.tabPanelButton.hidden = YES;
        popupController.maxSizeButton.hidden = YES;
    }
}


@end

