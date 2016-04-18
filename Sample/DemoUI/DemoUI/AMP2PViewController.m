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
    AVPlayer*       _player;
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
    _player = [AVPlayer playerWithPlayerItem:playerItem];*/
    
    if (_player != nil) {
        [_player removeObserver:self forKeyPath:@"status"];
    }
    
    _player = [AVPlayer playerWithURL:url];
    [_player addObserver:self forKeyPath:@"status" options:0 context:nil];
    
    
   // AVPlayer *player = A configured AVPlayer ojbect;
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    [_glView setLayer:playerLayer];
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


//use Video Tookit for h.264



@end
