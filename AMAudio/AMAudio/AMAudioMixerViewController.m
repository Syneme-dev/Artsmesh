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
#import "AMCollectionView.h"
#import "AMMixerViewController.h"
#import "AMMixerView.h"

@interface AMAudioMixerViewController ()<AMJackClientDelegate>

@property (weak) IBOutlet NSButton *startMixerBtn;
@property (weak) IBOutlet NSTextField *channelPairCount;
@property (weak) IBOutlet NSTextField *cpuUsage;
@property (weak) IBOutlet NSTextField *bufferSize;
@property (weak) IBOutlet NSTextField *sampleRate;
@property (weak) IBOutlet AMCollectionView *mixerCollectionView;

@end

@implementation AMAudioMixerViewController
{
    BOOL _mixerStarted;
    AMArtsmeshClient* _client;
    
    NSTimer* _jackInfoTimer;
    NSMutableArray *_mixerControllers;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here
    [self.mixerCollectionView setBackgroudColor:[NSColor blackColor]];
    self.mixerCollectionView.itemGap = 1;
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
    
    _mixerControllers = [[NSMutableArray alloc] init];
    NSArray* ports = [_client allPorts];
    
    for (AMJackPort* p in ports) {
       
        if (p.portType == AMJackPort_Source) {
            
            AMMixerViewController *mixerCtrl = [self createMixerByPort:p];
            p.volume = mixerCtrl.volume;
            
            [self.mixerCollectionView addViewItem:mixerCtrl.view];
            [_mixerControllers addObject:mixerCtrl];
        }
    }
    
    for (AMJackPort* p in ports) {
        
        if (p.portType == AMJackPort_Destination) {
            
            AMMixerViewController *mixerCtrl = [self createMixerByPort:p];
            p.volume = mixerCtrl.volume;
            
            [self.mixerCollectionView addViewItem:mixerCtrl.view];
            [_mixerControllers addObject:mixerCtrl];
        }
    }
    
    _jackInfoTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(updateJackInfo)
                                                    userInfo:nil repeats:YES];
    
    _client.delegate = self;
    
    return YES;
    
}

-(AMMixerViewController *)createMixerByPort:(AMJackPort *)p
{
    NSBundle* myBundle = [NSBundle bundleWithIdentifier:@"com.artsmesh.audioFramework"];
    AMMixerViewController* mixerCtrl = [[AMMixerViewController alloc] initWithNibName:@"AMMixerViewController" bundle:myBundle];
    [mixerCtrl setMeterRange:NSMakeRange(0, 1)];
    mixerCtrl.meter = 0.0;
    
    [mixerCtrl setVolumeRange:NSMakeRange(0, 1)];
    mixerCtrl.volume = 0.0;
    
    [(AMMixerView*)mixerCtrl.view setBackgroundColor:[NSColor colorWithCalibratedRed:46.0/255 green:58.0/255 blue:75.0/255 alpha:1]];
    //[(AMMixerView*)mixerCtrl.view setBackgroundColor:[NSColor lightGrayColor]];
    
    mixerCtrl.channName = p.name;
    [mixerCtrl addObserver:self forKeyPath:@"volume" options:NSKeyValueObservingOptionNew context:nil];
    
    return mixerCtrl;
}


#pragma mark -
#pragma   mark KVO
- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context
{
    if ([object isKindOfClass:[AMMixerViewController class]]){
        
        AMMixerViewController* mixerCtrl = (AMMixerViewController*)object;
        
        if ([keyPath isEqualToString:@"volume"]){
            NSArray* ports = [_client allPorts];
            for (AMJackPort* p in ports) {
                if ([p.name isEqualToString:mixerCtrl.channName]) {
                
                    p.volume = mixerCtrl.volume;
                }
            }
        }
    }
}


-(void)stopClient
{
    [_jackInfoTimer invalidate];
    _jackInfoTimer = nil;
    
    [_client unregisterClient];
    
    [self.mixerCollectionView removeAllItems];
    [_mixerControllers removeAllObjects];
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


//-(void)volumeBarChanged:(AMVolumeBar *)bar
//{
//    NSString* portName = bar.name;
//    
//    NSArray* ports = [_client allPorts];
//    for (AMJackPort* p in ports) {
//        if ([p.name isEqualToString:portName]) {
//            
//            p.isMute = bar.isMute;
//            p.volume = bar.volume;
//        }
//    }
//}

-(void)port:(AMJackPort *)port currentPeak:(float)peak
{
    for (AMMixerViewController* mc in _mixerControllers) {
        if ([mc.channName isEqualToString:port.name]){
            mc.meter = peak;
            break;
        }
    }
}


@end
