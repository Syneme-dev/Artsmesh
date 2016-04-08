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

NSString *const AMP2PVideoReceiverChanged;

@interface AMP2PViewController ()

@property (weak) IBOutlet AMSyphonView* glView;
//@property (weak) IBOutlet AVPlayerView* playerView;
@property (weak) IBOutlet NSPopUpButtonCell *serverTitlePopUpButton;
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
    serverURL = @"http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8";
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
}

-(void) observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context{
    if ([keyPath isEqualToString:@"status"]){
        AVPlayerStatus new = (AVPlayerStatus)change[NSKeyValueChangeNewKey];
//      AVPlayerStatus old = (AVPlayerStatus)change[NSKeyValueChangeOldKey];
//      if((old == AVPlayerStatusUnknown || old == AVPlayerStatusUnknown) && new == AVPlayerStatusReadyToPlay) {
        if(new == AVPlayerStatusReadyToPlay){
            [_player play];
        }
    }else {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    AMSyphonView *subView = [[AMSyphonView alloc] initWithFrame:NSMakeRect(0, 0, 300, 300)];
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
    self.glView.drawTriangle = YES;

    
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


@end
