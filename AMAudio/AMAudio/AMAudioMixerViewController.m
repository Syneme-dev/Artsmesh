//
//  AMAudioMixerView.m
//  AMAudio
//
//  Created by wangwei on 9/11/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMAudioMixerViewController.h"
#import "AMArtsmeshClient.h"
#import "AMAudio.h"
#import "AMVolumeCtlView.h"
#import "UIFramework/AMCollectionView.h"
#import "AMMixerViewController.h"
#import "AMMixerView.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "UIFramework/AMBigBlueButton.h"

@interface AMAudioMixerViewController ()<AMJackClientDelegate>

@property (weak) IBOutlet AMBigBlueButton *startMixerBtn;
@property (weak) IBOutlet NSTextField *bufferSize;
@property (weak) IBOutlet NSTextField *sampleRate;
@property (weak) IBOutlet AMCollectionView *mixerCollectionView;
@property (weak) IBOutlet AMCollectionView *outputMixerCollectionView;

@end

@implementation AMAudioMixerViewController
{
    BOOL _mixerStarted;
    AMArtsmeshClient* _client;
    
    NSTimer* _jackInfoTimer;
    NSTimer *_meterTimer;
    NSMutableDictionary *_mixerCtrls;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here
//    [self.mixerCollectionView setBackgroudColor:[NSColor redColor]];
//    [self.outputMixerCollectionView setBackgroudColor:[NSColor blueColor]];
    self.mixerCollectionView.itemGap = 1;
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(jackStopped:)
     name:AM_JACK_STOPPED_NOTIFICATION
     object:nil];
}

-(void)jackStopped:(NSNotification*)notification
{
    if(_mixerStarted)
    {
        [self.startMixerBtn performClick:nil];
    }
}

-(void)dealloc
{
    [self stopClient];
}


- (IBAction)startMixer:(NSButton *)sender
{
    if (_mixerStarted){
        [self stopClient];
        self.startMixerBtn.title = @"Start" ;
         [self.startMixerBtn setButtonOnState:NO];
        _mixerStarted = NO;
    }else{
        if ([self startClient]){
            self.startMixerBtn.title = @"Stop" ;
            [self.startMixerBtn setButtonOnState:YES];
            _mixerStarted = YES;
        }
    }
}

-(BOOL)startClient
{
    if(![[AMAudio sharedInstance] isJackStarted]){
        NSAlert *alert = [NSAlert alertWithMessageText:@"State Error"
                                         defaultButton:@"Ok" alternateButton:nil
                                           otherButton:nil
                             informativeTextWithFormat:@"Should Start Jack Server first!"];
        [alert runModal];
        return NO;
    }

    int virtualChanns = [[[AMPreferenceManager standardUserDefaults] valueForKey:Preference_Jack_RouterVirtualChanns] intValue];
    
    if(virtualChanns < 0 || virtualChanns > 8){
        NSLog(@"virtual channels is not in range, set to 2, current value:%d", virtualChanns);
        virtualChanns = 2;
    }
    
    //Check virtual input or output channels
    int virtualInChannels = [[[AMPreferenceManager standardUserDefaults] valueForKey:Preference_Jack_VirtualInChannels] intValue];
    int virtualOutChannels = [[[AMPreferenceManager standardUserDefaults] valueForKey:Preference_Jack_VirtualOutChannels] intValue];
    
    if(virtualInChannels  < 0 || virtualInChannels  > 8 ||
       virtualOutChannels < 0 || virtualOutChannels > 8){
        NSLog(@"virtual input or output channels is not in range, set to 2, current value:%d", virtualChanns);
        virtualInChannels  = 2;
        virtualOutChannels = 2;
    }

    
    
    _client = [[AMArtsmeshClient alloc] initWithChannelCounts:virtualChanns];
    if (![_client registerClient])
    {
        return NO;
    };
    
    _mixerCtrls = [[NSMutableDictionary alloc] init];
    NSArray* ports = [_client allPorts];
    
    for (AMJackPort* p in ports) {
       
        if (p.portType == AMJackPort_Source) {
            
            AMMixerViewController *mixerCtrl = [self createMixerByPort:p];
            [self.mixerCollectionView addViewItem:mixerCtrl.view];
            [_mixerCtrls setObject:mixerCtrl forKey:mixerCtrl.channName];
        }
    }
    
    for (AMJackPort* p in ports) {
        
        if (p.portType == AMJackPort_Destination) {
            
            AMMixerViewController *mixerCtrl = [self createMixerByPort:p];
            [self.outputMixerCollectionView addViewItem:mixerCtrl.view];
            [_mixerCtrls setObject:mixerCtrl forKey:mixerCtrl.channName];
        }
    }
    
    _jackInfoTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(updateJackInfo)
                                                    userInfo:nil repeats:YES];
    _meterTimer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                   target:self
                                                 selector:@selector(updateChannelPeak)
                                                 userInfo:nil
                                                  repeats:YES];
    
    _client.delegate = self;
    
    return YES;
    
}

-(void)updateChannelPeak
{
    
    NSArray* ports = [_client allPorts];
    for (AMJackPort* p in ports) {
        NSString *portName = [p.name uppercaseString];
        AMMixerViewController* ctrl = [_mixerCtrls objectForKey:portName];
        ctrl.meter = p.tempPeak * 100;
    }
}

-(AMMixerViewController *)createMixerByPort:(AMJackPort *)p
{
    NSBundle* myBundle = [NSBundle bundleWithIdentifier:@"com.artsmesh.audioFramework"];
    AMMixerViewController* mixerCtrl = [[AMMixerViewController alloc] initWithNibName:@"AMMixerViewController" bundle:myBundle];
    [mixerCtrl setMeterRange:NSMakeRange(0, 1)];
    mixerCtrl.meter = 0.0;
    
    [mixerCtrl setVolumeRange:NSMakeRange(0, 1)];
    mixerCtrl.volume = 0.5;
    [(AMMixerView*)mixerCtrl.view
     setBackgroundColor:[NSColor colorWithCalibratedRed:38.0/255 green:38.0/255 blue:38.0/255 alpha:1]];
    mixerCtrl.jackport = p;
    mixerCtrl.channName = p.name;
    p.volume = mixerCtrl.volume;
    
    return mixerCtrl;
}


-(void)stopClient
{
    [_meterTimer invalidate];
    _meterTimer = nil;
    
    [_jackInfoTimer invalidate];
    _jackInfoTimer = nil;
    
    [_client unregisterClient];
    
    [self.mixerCollectionView removeAllItems];
    [self.outputMixerCollectionView removeAllItems];
    
    [_mixerCtrls removeAllObjects];
}


-(void)updateJackInfo
{
    NSString* strBufSize = [NSString stringWithFormat:@"%d", [_client bufferSize]];
    NSString* strSampleRate = [NSString stringWithFormat:@"%d", [_client sampleRate]];
    self.bufferSize.stringValue = strBufSize;
    self.sampleRate.stringValue = strSampleRate;
}



@end
