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

@interface AMAudio()
@end

@implementation AMAudio
{
    AMJackManager* _jackManager;
    AMJackTripManager* _jacktripManager;
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
    }
    
    return _routerController;
}

-(NSViewController*)getJacktripPrefUI
{
    if (_jackTripController == nil) {
        NSBundle* myBundle = [NSBundle bundleWithIdentifier:@"com.artsmesh.audioFramework"];
        _jackTripController = [[AMJackTripConfigController alloc] initWithNibName:@"AMJackTripConfigController" bundle:myBundle];
    }
    
    return _jackTripController;
}

-(BOOL)startJack
{
    return [_jackManager startJack];
}

-(void)stopJack
{
    return [_jackManager stopJack];
}

@end
