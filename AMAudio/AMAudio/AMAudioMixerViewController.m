//
//  AMAudioMixerView.m
//  AMAudio
//
//  Created by wangwei on 9/11/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMAudioMixerViewController.h"
#import "AMVolumeBar.h"
#import "AMArtsmeshClient.h"
#import "AMAudio.h"
#import "AMVolumeCtlView.h"

@interface AMAudioMixerViewController ()<AMVolumeBarDelegate>

@property (weak) IBOutlet NSButton *startMixerBtn;
@property (weak) IBOutlet NSTextField *channelPairCount;
@property (weak) IBOutlet NSCollectionView *controlView;
@property (weak) IBOutlet NSTextField *cpuUsage;
@property (weak) IBOutlet NSTextField *bufferSize;
@property (weak) IBOutlet NSTextField *sampleRate;

@end

@implementation AMAudioMixerViewController
{
    BOOL _mixerStarted;
    AMArtsmeshClient* _client;
    
    NSTimer* _jackInfoTimer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here
}

-(void)dealloc
{
    [self stopClient];
}


- (IBAction)startMixer:(NSButton *)sender
{
    if (_mixerStarted){
        [self stopClient];
        self.startMixerBtn.title = @"Start Mixer" ;
        _mixerStarted = NO;
    }else{
        if ([self startClient]){
            self.startMixerBtn.title = @"Stop Mixer" ;
            _mixerStarted = YES;
        }
    }
}

-(BOOL)startClient
{
    if(![[AMAudio sharedInstance] isJackStarted]){
        NSAlert *alert = [NSAlert alertWithMessageText:@"State Error" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Should Start Jack Server first!"];
        [alert runModal];
        return NO;
    }
    
    int count = [self.channelPairCount.stringValue intValue];
    if(count < 1 || count > 8){
        NSAlert *alert = [NSAlert alertWithMessageText:@"Parameter Error" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Channel count should be between 1 and 8"];
        [alert runModal];
        return NO;
    }

    _client = [[AMArtsmeshClient alloc] initWithChannelCounts:count];
    if (![_client registerClient])
    {
        return NO;
    };
    
    NSArray* ports = [_client allPorts];
    
    NSMutableArray* barCollection =[[NSMutableArray alloc] init];
    for (AMJackPort* p in ports) {
       
        if (p.portType == AMJackPort_Source) {
            AMVolumeBar *bar = [[AMVolumeBar alloc] init];
            bar.volume = 0.5;
            bar.meter = 0.5;
            bar.isMute = NO;
            bar.name = p.name;
            bar.delegate = self;
            [barCollection addObject:bar];
            
            p.volume = bar.volume;
        }
    }
    
    for (AMJackPort* p in ports) {
        
        if (p.portType == AMJackPort_Destination) {
            AMVolumeBar *bar = [[AMVolumeBar alloc] init];
            bar.volume = 0.4;
            bar.meter = 0.4;
            bar.isMute = NO;
            bar.name = p.name;
            bar.delegate = self;
            [barCollection addObject:bar];
        }
    }
    
    [self.controlView setContent:barCollection];
    
    _jackInfoTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(updateJackInfo)
                                                    userInfo:nil repeats:YES];
    
    return YES;
    
}

-(void)stopClient
{
    [_jackInfoTimer invalidate];
    _jackInfoTimer = nil;
    
    [_client unregisterClient];
    
    [self.controlView setContent:[[NSMutableArray alloc] init]];
}

-(void)updateJackInfo
{
    NSString* strCPULoad = [NSString stringWithFormat:@"%.2f", [_client cpuLoad]];
    NSString* strBufSize = [NSString stringWithFormat:@"%d", [_client bufferSize]];
    NSString* strSampleRate = [NSString stringWithFormat:@"%d", [_client sampleRate]];
    
    self.cpuUsage.stringValue = strCPULoad;
    self.bufferSize.stringValue = strBufSize;
    self.sampleRate.stringValue = strSampleRate;
}


-(void)volumeBarChanged:(AMVolumeBar *)bar
{
    NSString* portName = bar.name;
    
    NSArray* ports = [_client allPorts];
    for (AMJackPort* p in ports) {
        if ([p.name isEqualToString:portName]) {
            
            p.isMute = bar.isMute;
            p.volume = bar.volume;
        }
    }
}


@end
