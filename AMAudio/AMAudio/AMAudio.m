//
//  AMAudio.m
//  AMAudio
//
//  Created by 王 为 on 8/22/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMAudio.h"
#import "AMRouteViewController.h"
#import "AMJackTripConfig.h"
#import "AMAudioMixerViewController.h"


@interface AMAudio()
@end

@implementation AMAudio
{
    AMJackManager* _jackManager;
    AMJackTripManager* _jacktripManager;
    AMJackClient* _jackClient;
    AMRouteViewController* _routerController;
    AMJackTripConfig* _jackTripController;
    AMAudioMixerViewController* _mixerViewController;
    AMAudioDeviceManager *_audioDevManager;
    
}

+(id)sharedInstance
{
    static AMAudio* sharedInstance = nil;
    @synchronized(self){
        if (sharedInstance == nil){
            sharedInstance = [[self alloc] privateInit];
        }
    }
    return sharedInstance;
}

-(id)init
{
    return [AMAudio sharedInstance];
}

-(id)privateInit
{
   
    
    
    
    return self;
}


-(AMAudioDeviceManager *)audioDeviceManager
{
    if (_audioDevManager == nil) {
        _audioDevManager = [[AMAudioDeviceManager alloc] init];
    }
    
    return _audioDevManager;
}

-(AMJackClient *)audioJackClient
{
    if(_jackClient == nil){
        _jackClient = [[AMJackClient alloc] init];
    }
    
    return _jackClient;
}


-(AMJackTripManager *)audioJacktripManager
{
    if (_jacktripManager == nil) {
        _jacktripManager = [[AMJackTripManager alloc] init];
    }
    
    return _jacktripManager;
}


-(AMJackManager *)audioJackManager
{
    if (_jackManager == nil) {
         _jackManager = [[AMJackManager alloc] init];
    }
    
    return _jackManager;
}


-(void)releaseResources
{
    [[self audioJacktripManager] stopAllJacktrips];
    [[self audioJackManager] stopJack];
    
    _jackManager = nil;
    _jacktripManager = nil;
}


-(void)dealloc
{
    [self releaseResources];
}

-(BOOL)isJackStarted
{
    return [self audioJackManager].jackState == JackState_Started;
}


-(NSViewController*)getJackRouterUI
{
    if (_routerController == nil) {
        NSBundle* myBundle = [NSBundle bundleWithIdentifier:@"com.artsmesh.audioFramework"];
        _routerController = [[AMRouteViewController alloc] initWithNibName:@"AMRouteViewController" bundle:myBundle];
    }
    
    return _routerController;
}


-(NSViewController*)getMixerUI
{
    if (_mixerViewController == nil) {
        NSBundle* myBundle = [NSBundle bundleWithIdentifier:@"com.artsmesh.audioFramework"];
        _mixerViewController = [[AMAudioMixerViewController alloc] initWithNibName:@"AMAudioMixerViewController" bundle:myBundle];
    }
    
    return _mixerViewController;
}

-(BOOL)startJack
{
    return [[self audioJackManager] startJack];
}

-(float)jackCpuUsage
{
    return [[self audioJackClient] cpuUsage];
}

-(void)stopJack
{
    [[self audioJackClient] closeJackClient];
    [[self audioJackManager] stopJack];
}

-(void)stopJacktrips
{
    [[self audioJacktripManager] stopAllJacktrips];
}

@end
