//
//  AMVideo.m
//  AMVideo
//
//  Created by robbin on 11/17/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import "AMVideo.h"
#import "AMVideoMixerViewController.h"

@implementation AMVideo
{
    AMVideoMixerViewController *_mixerViewController;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static id sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[AMVideo alloc] init];
    });
    
    return sharedInstance;
}

- (NSViewController *)getMixerUI
{
    if (_mixerViewController == nil) {
        NSBundle* myBundle = [NSBundle bundleWithIdentifier:@"com.artsmesh.videoFramework"];
        _mixerViewController = [[AMVideoMixerViewController alloc] initWithNibName:@"AMVideoMixerViewController" bundle:myBundle];
    }
    return _mixerViewController;
}

- (void)startSyphon
{
    if(_mixerViewController){
        if(_mixerViewController.syphonClientsManager){
            [_mixerViewController.syphonClientsManager startRouter];
        }
    }
}

- (void)stopSyphon
{
    if(_mixerViewController){
        if(_mixerViewController.syphonClientsManager){
            [_mixerViewController.syphonClientsManager stopRouter];
        }
    }
}

-(BOOL)isSyphonServerStarted
{
    if(_mixerViewController){
        if(_mixerViewController.syphonClientsManager){
            return [_mixerViewController.syphonClientsManager isSyphonServerStarted];
        }
    }
    
    return NO;
}

@end
