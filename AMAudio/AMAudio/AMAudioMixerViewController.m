//
//  AMAudioMixerView.m
//  AMAudio
//
//  Created by wangwei on 9/11/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMAudioMixerViewController.h"
#import "AMVolumeBar.h"

@interface AMAudioMixerViewController ()<NSCollectionViewDelegate>

@property (weak) IBOutlet NSButton *startMixerBtn;
@property (weak) IBOutlet NSTextField *channelPairCount;
@property (weak) IBOutlet NSCollectionView *controlView;

@end

@implementation AMAudioMixerViewController
{
    BOOL _mixerStarted;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.

    
    NSMutableArray* tes =[[NSMutableArray alloc] init];
    
    AMVolumeBar *bar = [[AMVolumeBar alloc] init];
    bar.volume = 0.9;
    bar.meter = 0.5;
    bar.isMute = YES;
    [tes addObject:bar];
    

    
    for (int i = 0; i < 5; i++) {
        AMVolumeBar *bar1 = [[AMVolumeBar alloc] init];
        bar1.volume = 0.9;
        bar1.meter = 0.5;
        bar1.isMute = NO;
        [tes addObject:bar1];
    }
    
    [self.controlView setContent:tes];
    
}

- (IBAction)startMixer:(NSButton *)sender
{
    if (_mixerStarted){
        self.startMixerBtn.title = @"Start Mixer" ;
        _mixerStarted = NO;
    }else{
        self.startMixerBtn.title = @"Stop Mixer" ;
        _mixerStarted = YES;
    }
}






@end
