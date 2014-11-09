//
//  AMAudioMixerView.m
//  AMAudio
//
//  Created by wangwei on 9/11/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMAudioMixerViewController.h"

@interface AMAudioMixerViewController ()
@property (weak) IBOutlet NSButton *startMixerBtn;
@property (weak) IBOutlet NSTextField *channelPairCount;

@end

@implementation AMAudioMixerViewController
{
    BOOL _mixerStarted;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
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
