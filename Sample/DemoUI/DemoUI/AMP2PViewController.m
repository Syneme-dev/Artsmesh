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


#include "AMLogger/AMLogger.h"
#include <stdio.h>      /* standard C i/o facilities */
#include <stdlib.h>     /* needed for atoi() */
#include <unistd.h>     /* defines STDIN_FILENO, system calls,etc */
#include <sys/types.h>  /* system data type definitions */
#include <sys/socket.h> /* socket specific definitions */
#include <netinet/in.h> /* INET constants and stuff */
#include <arpa/inet.h>  /* IP address conversion stuff */
#include <netdb.h>      /* gethostbyname */
// this routine echos any messages (UDP datagrams) received
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


@interface AMP2PViewController ()

@property (weak) IBOutlet NSView* glView;
//@property (weak) IBOutlet AVPlayerView* playerView;
@property (weak) IBOutlet NSPopUpButtonCell *serverTitlePopUpButton;

//VT for deocde h.264
@property (nonatomic, assign) CMVideoFormatDescriptionRef   formatDesc;
@property (nonatomic, assign) VTDecompressionSessionRef     decompressionSession;
@property (nonatomic, retain) AVSampleBufferDisplayLayer*   videoLayer;
@property (nonatomic, assign) int                           spsSize;
@property (nonatomic, assign) int                           ppsSize;



@end

@implementation AMP2PViewController
{
    AVPlayer*                       _player;
    AVSampleBufferDisplayLayer*     _avsbDisplayLayer;
}

- (void) dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)serverSelected:(NSPopUpButton*)sender {
    NSString* serverURL = [NSString stringWithFormat:@"udp://%@", sender.selectedItem.title];
    NSURL *url = [NSURL URLWithString:serverURL];
    
    // You may find a test stream at <http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8>.
  /*  AVPlayerItem*  playerItem = [AVPlayerItem playerItemWithURL:url];
    [playerItem addObserver:self forKeyPath:@"status" options:0 context:nil];
    _player = [AVPlayer playerWithPlayerItem:playerItem];
    
    if (_player != nil) {
        [_player removeObserver:self forKeyPath:@"status"];
    }
    
    _player = [AVPlayer playerWithURL:url];
    [_player addObserver:self forKeyPath:@"status" options:0 context:nil];
    
    
   // AVPlayer *player = A configured AVPlayer ojbect;
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    [_glView setLayer:playerLayer];
    */
   
    
    NSString* strURL = sender.selectedItem.title;
    //[strURL rangeOfString:];
    NSUInteger commaPosition =[strURL rangeOfString:@":"].location;
    if(commaPosition != NSNotFound){
        NSString* strPort = [strURL substringFromIndex:commaPosition+1];
        int ld =[self initUDPConfig:[strPort integerValue]];
        if(ld != -1){
            [self parseH264NAL:ld];
        }
        close(ld);
    }
   

}

- (void) parseH264NAL:(int) sd{
    int len,n;
    char bufin[MAXBUF];
    struct sockaddr_in remote;
    
    // need to know how big address struct is, len must be set before the call to recvfrom!!!
    len = sizeof(remote);
    int index = 0;
    
    UInt8 tmpStartCode[3];
    
    tmpStartCode[0] = 0x00;
    tmpStartCode[1] = 0x00;
    tmpStartCode[2] = 0x01;
    
    NSData *startCode = [NSData dataWithBytes:&tmpStartCode length:3];
    NSMutableData* lastNALUData = nil;
    
    while (index < 300) { // 30 seconds
        /// read a datagram from the socket (put result in bufin)
        n=recvfrom(sd,bufin, MAXBUF, 0, (struct sockaddr *)&remote, &len);
        if (n == 0)
            continue;
        
        
        index++;
        NSData* recvData = [[NSData alloc] initWithBytes:bufin length:n];
        
        bool findHeader = NO;
        NSRange range;
        
        range = [recvData rangeOfData:startCode options:nil
                                        range:NSMakeRange(0, [recvData length])];
        
        while(range.location != NSNotFound){
            if (range.location != NSNotFound) {
                if(lastNALUData != nil && range.location != 0){
                    if(lastNALUData == nil){ //the first time to receive
                        lastNALUData = [[NSMutableData alloc] initWithBytes:(uint8_t*)recvData.bytes
                                                          length:range.length];
                    }else{
                        [lastNALUData appendBytes:(uint8_t*)recvData.bytes
                                           length:range.length-1];
                    
                        [self receivedRawVideoFrame:(uint8_t*)lastNALUData.bytes
                                           withSize:[lastNALUData length]
                                           isIFrame:1];
                    
                            lastNALUData = [[NSMutableData alloc]
                                                initWithBytes:(uint8_t*)recvData.bytes + range.length
                                                length:range.length];
                    }
                    
                    range = [recvData rangeOfData:startCode
                                          options:nil
                                            range:NSMakeRange(range.location+1, [recvData length]-range.length)];
                    continue;
                }
            }else{ //Not found
                if(lastNALUData != nil)
                    [lastNALUData appendData:recvData];
                break;
            }
            
        }
        
        
    }

    
}

- (void) writeH264NALToFile: (int) sd
{
    int len,n;
    char bufin[MAXBUF];
    struct sockaddr_in remote;
    
    // need to know how big address struct is, len must be set before the call to recvfrom!!!    
    len = sizeof(remote);
    int fileIndex = 0;

    ///////
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *directory = AMLogDirectory();
    BOOL isDirectory;
    
    if (![fileManager fileExistsAtPath:directory isDirectory:&isDirectory]) {
        isDirectory = [fileManager createDirectoryAtPath:directory
                             withIntermediateDirectories:NO
                                              attributes:nil
                                                   error:nil];
    }
    /////////
    
    while (fileIndex <= 1000) {
        /// read a datagram from the socket (put result in bufin)
        n=recvfrom(sd,bufin, MAXBUF, 0, (struct sockaddr *)&remote, &len);
        if (n == 0)
            continue;
        
        
        if(n<0) {
            NSLog(@"Error receiving data");
            continue;
        }
        
        
        fileIndex++;
        NSData* recvData = [[NSData alloc] initWithBytes:bufin length:n];
        NSString* nalFilePath = [NSString stringWithFormat:@"nal_%d",fileIndex];
        
        [fileManager createFileAtPath:nalFilePath contents:recvData attributes:nil];
    }
}


-(int) initUDPConfig:(NSUInteger)nPort {
    
    int ld;
    struct sockaddr_in skaddr;
    int length;
    
    // create a socket IP protocol family (PF_INET) UDP protocol (SOCK_DGRAM)
    
    
    if ((ld = socket( PF_INET, SOCK_DGRAM, 0 )) < 0) {
        NSLog(@"Problem creating socket\n");
        return -1;
    }
    
    // establish our address address family is AF_INET our IP address is INADDR_ANY
    // (any of our IP addresses) the port number is assigned by the kernel
    
    skaddr.sin_family = AF_INET;
    skaddr.sin_addr.s_addr = htonl(INADDR_ANY);
    skaddr.sin_port = htons(nPort);
    
    if (bind(ld, (struct sockaddr *) &skaddr, sizeof(skaddr))<0) {
        NSLog(@"Problem binding\n");
        return -1;
    }
    
    // find out what port we were assigned and print it out
    length = sizeof( skaddr );
    if (getsockname(ld, (struct sockaddr *) &skaddr, &length)<0) {
        NSLog(@"Error getsockname\n");
        return -1;
    }
    
    // port number's are network byte order, we have to convert to
    // host byte order before printing !
    NSLog(@"The server UDP port number is %d\n",ntohs(skaddr.sin_port));
    
    // Go echo every datagram we get
    
    return ld;
}



-(void) observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context{
    if ([keyPath isEqualToString:@"status"]){
        [_player play];
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


- (void) render:(CMSampleBufferRef)sampleBuffer
{
    // [_avDisplayLayer enqueueSampleBuffer:sampleBuffer];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    NSView *subView = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 300, 300)];
    self.glView = subView;
    [self.view addSubview:subView];
    
    [subView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSView *content = subView;
    NSDictionary *views = NSDictionaryOfVariableBindings(content);
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[content]-0-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[content]-0-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
//    self.glView.drawTriangle = YES;

    
    [self updateServerTitle];
    NSNotificationCenter* defaultNC = [NSNotificationCenter defaultCenter];
    [defaultNC addObserver:self
                  selector:@selector(updateServerTitle)
                      name:AMP2PVideoReceiverChanged
                    object:nil];
    
    
    // Since we're using AVSampleBufferDisplayLayer, init the layer like this:
    // create our AVSampleBufferDisplayLayer and add it to the view
    _avsbDisplayLayer = [[AVSampleBufferDisplayLayer alloc] init];
    _avsbDisplayLayer.frame = self.view.frame;
    _avsbDisplayLayer.bounds = self.view.bounds;
    _avsbDisplayLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    // set Timebase, you may need this if you need to display frames at specific times
    // Maybe not working, since I haven't verified wheterh the timebase is working
    CMTimebaseRef controlTimebase;
    CMTimebaseCreateWithMasterClock(CFAllocatorGetDefault(), CMClockGetHostTimeClock(), &controlTimebase);
    
    //videoLayer.controlTimebase = controlTimebase;
    CMTimebaseSetTime(self.videoLayer.controlTimebase, kCMTimeZero);
    CMTimebaseSetRate(self.videoLayer.controlTimebase, 1.0);
    
    [self.glView setLayer:_avsbDisplayLayer];
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
-(void) receivedRawVideoFrame:(uint8_t *)frame withSize:(uint32_t)frameSize isIFrame:(int)isIFrame
{
    OSStatus status;
    
    uint8_t *data = NULL;
    uint8_t *pps = NULL;
    uint8_t *sps = NULL;
    
    // For our example of H.264 data source's NALUs, the start-code index should be always 0.
    // If you don't know where it starts, you can use a for loop similar to
    // how i find the 2nd and 3rd start codes.
    
    int startCodeIndex = 0;
    int secondStartCodeIndex = 0;
    int thirdStartCodeIndex = 0;
    
    long blockLength = 0;
    
    CMSampleBufferRef sampleBuffer = NULL;
    CMBlockBufferRef blockBuffer = NULL;
    
    int nalu_type = (frame[startCodeIndex + 4] & 0x1F);
    NSLog(@"Later AMLog: Received NALU Type \"%@\" ", naluTypesStrings[nalu_type]);
    
    // If we haven't already set up our format description with our SPS PPS parameters,
    // we can't process any frames except type 7 that has our parameters
    if (nalu_type != 7 && _formatDesc == NULL)
    {
        NSLog(@"Later AMLog video error: Frame is not an I Frame and format description is null");
        return;
    }
    
    // NALU type 7 is the SPS parameter NALU
    if (nalu_type == 7)
    {
        // Find where the second PPS start code begins, (the 0x00 00 01 code)
        // from which we also get the length of the first SPS code
        for (int i = startCodeIndex + 4; i < startCodeIndex + 40; i++)
        {
            if (frame[i] == 0x00 && frame[i+1] == 0x00 && frame[i+2] == 0x01)
            {
                secondStartCodeIndex = i;
                _spsSize = secondStartCodeIndex;   // includes the header in the size
                break;
            }
        }
        
        // Find what the second NALU type is
        nalu_type = (frame[secondStartCodeIndex + 3] & 0x1F);
        NSLog(@"~~~~~~~ Received NALU Type \"%@\" ~~~~~~~~", naluTypesStrings[nalu_type]);
    }
    
    // type 8 is the PPS parameter NALU
    if(nalu_type == 8)
    {
        // Find where the NALU after this one starts so we know how long the PPS parameter is
        for (int i = _spsSize + 4; i < _spsSize + 30; i++)
        {
            if (frame[i] == 0x00 && frame[i+1] == 0x00 && frame[i+2] == 0x00 && frame[i+3] == 0x01)
            {
                thirdStartCodeIndex = i;
                _ppsSize = thirdStartCodeIndex - _spsSize;
                break;
            }
        }
        
        // Allocate enough data to fit the SPS and PPS parameters into our data objects.
        // VTD doesn't want you to include the start code header (4 bytes long) so we add the - 4 here
        sps = malloc(_spsSize - 4);
        pps = malloc(_ppsSize - 4);
        
        // copy in the actual sps and pps values, again ignoring the 4 byte header
        memcpy (sps, &frame[4], _spsSize-4);
        memcpy (pps, &frame[_spsSize+4], _ppsSize-4);
        
        // now we set our H264 parameters
        uint8_t*  parameterSetPointers[2] = {sps, pps};
        size_t parameterSetSizes[2] = {_spsSize-4, _ppsSize-4};
        
        status = CMVideoFormatDescriptionCreateFromH264ParameterSets(kCFAllocatorDefault, 2,
                                                                     (const uint8_t *const*)parameterSetPointers,
                                                                     parameterSetSizes, 4,
                                                                     &_formatDesc);
        
        NSLog(@"\t\t Creation of CMVideoFormatDescription: %@", (status == noErr) ? @"successful!" : @"failed...");
        if(status != noErr) NSLog(@"\t\t Format Description ERROR type: %d", (int)status);
        
        // See if decomp session can convert from previous format description
        // to the new one, if not we need to remake the decomp session.
        // This snippet was not necessary for my applications but it could be for yours
        /*BOOL needNewDecompSession = (VTDecompressionSessionCanAcceptFormatDescription(_decompressionSession, _formatDesc) == NO);
         if(needNewDecompSession)
         {
         [self createDecompSession];
         }*/
        
        // now lets handle the IDR frame that (should) come after the parameter sets
        // I say "should" because that's how I expect my H264 stream to work, YMMV
        nalu_type = (frame[thirdStartCodeIndex + 4] & 0x1F);
        NSLog(@"Later AMLog:Received NALU Type \"%@\" ", naluTypesStrings[nalu_type]);
    }
    
  
    
    // Type 5 is an IDR frame NALU.  The SPS and PPS NALUs should always be followed by an IDR
    // (or IFrame) NALU.
    if(nalu_type == 5)
    {
        // Find the offset, or where the SPS and PPS NALUs end and the IDR frame NALU begins
        int offset = _spsSize + _ppsSize;
        blockLength = frameSize - offset;
        data = malloc(blockLength);
        data = memcpy(data, &frame[offset], blockLength);
        
        // Replace the start code header on this NALU with its size.
        // AVCC format requires that you do this.
        // htonl converts the unsigned int from host to network byte order
        uint32_t dataLength32 = htonl (blockLength - 4);
        memcpy (data, &dataLength32, sizeof (uint32_t));
        
        // Create a block buffer from the IDR NALU
        status = CMBlockBufferCreateWithMemoryBlock(NULL, data,  // memoryBlock to hold buffered data
                                                    blockLength,  // block length of the mem block in bytes.
                                                    kCFAllocatorNull, NULL,
                                                    0, // offsetToData
                                                    blockLength,   // dataLength of relevant bytes, starting at offsetToData
                                                    0, &blockBuffer);
        
        NSLog(@"\t\t BlockBufferCreation: \t %@", (status == kCMBlockBufferNoErr) ? @"successful!" : @"failed...");
    }
    
    // NALU type 1 is non-IDR (or PFrame) picture
    if (nalu_type == 1)
    {
        // non-IDR frames do not have an offset due to SPS and PSS, so the approach
        // is similar to the IDR frames just without the offset
        blockLength = frameSize;
        data = malloc(blockLength);
        data = memcpy(data, &frame[0], blockLength);
        
        // again, replace the start header with the size of the NALU
        uint32_t dataLength32 = htonl (blockLength - 4);
        memcpy (data, &dataLength32, sizeof (uint32_t));
        
        status = CMBlockBufferCreateWithMemoryBlock(NULL, data,  // memoryBlock to hold data. If NULL, block will be alloc when needed
                                                    blockLength,  // overall length of the mem block in bytes
                                                    kCFAllocatorNull, NULL,
                                                    0,     // offsetToData
                                                    blockLength,  // dataLength of relevant data bytes, starting at offsetToData
                                                    0, &blockBuffer);
        
        NSLog(@"\t\t BlockBufferCreation: \t %@", (status == kCMBlockBufferNoErr) ? @"successful!" : @"failed...");
    }
    
    // now create our sample buffer from the block buffer,
    if(status == noErr)
    {
        // here I'm not bothering with any timing specifics since in my case we displayed all frames immediately
        const size_t sampleSize = blockLength;
        status = CMSampleBufferCreate(kCFAllocatorDefault,
                                      blockBuffer, true, NULL, NULL,
                                      _formatDesc, 1, 0, NULL, 1,
                                      &sampleSize, &sampleBuffer);
        
        NSLog(@"\t\t SampleBufferCreate: \t %@", (status == noErr) ? @"successful!" : @"failed...");
    }
    
    if(status == noErr)
    {
        // set some values of the sample buffer's attachments
        CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, YES);
        CFMutableDictionaryRef dict = (CFMutableDictionaryRef)CFArrayGetValueAtIndex(attachments, 0);
        CFDictionarySetValue(dict, kCMSampleAttachmentKey_DisplayImmediately, kCFBooleanTrue);
        
        // Later send the samplebuffer to to an AVSampleBufferDisplayLayer
        //[self render:sampleBuffer];
    }
    
    // free memory to avoid a memory leak, do the same for sps, pps and blockbuffer
    if (NULL != data)
    {
        free (data);
        data = NULL;
    }
}



@end
