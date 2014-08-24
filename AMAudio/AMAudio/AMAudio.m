//
//  AMAudio.m
//  AMAudio
//
//  Created by 王 为 on 8/22/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMAudio.h"
#import "AMAudioPrefViewController.h"
#import "AMJackConfigs.h"

@implementation AMAudio
{
    AMAudioPrefViewController* _prefController;
    AMJackConfigs* _configs;
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
    return nil;
}

-(id)privateInit
{
    _configs = [AMJackConfigs initWithArchiveConfig];
    return self;
}

-(NSViewController*)getJackPrefUI
{
    if (_prefController == nil) {
       NSBundle* myBundle = [NSBundle bundleWithIdentifier:@"com.artsmesh.audioFramework"];
        _prefController = [[AMAudioPrefViewController alloc] initWithNibName:@"AMAudioPrefViewController" bundle:myBundle];
    }
    
    return _prefController;
}

-(BOOL)startJack
{
    int n = system("killall -0 jackdmp >/dev/null");
    if (n == 0) {
        return YES;
    }
    
    NSString* command =  [_configs formatCommandLine];
    
    return YES;
}


@end
