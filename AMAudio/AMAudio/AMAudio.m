//
//  AMAudio.m
//  AMAudio
//
//  Created by 王 为 on 8/22/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMAudio.h"
#import "AMJackManager.h"
#import "AMJackTripManager.h"
#import "AMAudioPrefViewController.h"
#import "AMRouteViewController.h"
#import "AMJackTripConfigController.h"
#import "AMJackClient.h"

@interface AMAudio()
@end

@implementation AMAudio
{
    AMJackManager* _jackManager;
    AMJackTripManager* _jacktripManager;
    AMJackClient* _jackClient;
    AMAudioPrefViewController* _prefController;
    AMRouteViewController* _routerController;
    AMJackTripConfigController* _jackTripController;
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
    _jackManager = [[AMJackManager alloc] init];
    _jacktripManager = [[AMJackTripManager alloc] init];
    _jackClient = [[AMJackClient alloc] init];
    
    return self;
}

-(void)releaseResources
{
    [_jacktripManager stopAllJacktrips];
    [_jackManager stopJack];
    
    _jackManager = nil;
    _jacktripManager = nil;
}

-(void)dealloc
{
    [self releaseResources];
}

-(BOOL)isJackStarted
{
    return _jackManager.jackState == JackState_Started;
}

-(NSViewController*)getJackPrefUI
{
    if (_prefController == nil) {
       NSBundle* myBundle = [NSBundle bundleWithIdentifier:@"com.artsmesh.audioFramework"];
        _prefController = [[AMAudioPrefViewController alloc] initWithNibName:@"AMAudioPrefViewController" bundle:myBundle];
        _prefController.jackManager = _jackManager;
    }
    
    return _prefController;
}

-(NSViewController*)getJackRouterUI
{
    if (_routerController == nil) {
        NSBundle* myBundle = [NSBundle bundleWithIdentifier:@"com.artsmesh.audioFramework"];
        _routerController = [[AMRouteViewController alloc] initWithNibName:@"AMRouteViewController" bundle:myBundle];
        _routerController.jackClient = _jackClient;
        _routerController.jackManager = _jackManager;
        _routerController.jacktripManager = _jacktripManager;
    }
    
    return _routerController;
}

-(NSViewController*)getJacktripPrefUI
{
    if (_jackTripController == nil) {
        NSBundle* myBundle = [NSBundle bundleWithIdentifier:@"com.artsmesh.audioFramework"];
        _jackTripController = [[AMJackTripConfigController alloc] initWithNibName:@"AMJackTripConfigController" bundle:myBundle];
        _jackTripController.jacktripManager = _jacktripManager;
        _jackTripController.jackManager = _jackManager;
    }
    
    return _jackTripController;
}

-(BOOL)startJack
{
    [_jackManager startJack];
    
    return YES;
}

-(void)stopJack
{
    [_jackClient closeJackClient];
    [_jackManager stopJack];
}

-(void)stopJacktrips
{
    [_jacktripManager stopAllJacktrips];
}

@end
