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
        if(_mixerViewController.syphonManager){
            [_mixerViewController.syphonManager startRouter];
        }
    }
}

- (void)stopSyphon
{
    if(_mixerViewController){
        if(_mixerViewController.syphonManager){
            [_mixerViewController.syphonManager stopRouter];
        }
    }
}

-(BOOL)isSyphonServerStarted
{
    if(_mixerViewController){
        if(_mixerViewController.syphonManager){
            return [_mixerViewController.syphonManager isSyphonServerStarted];
        }
    }
    
    return NO;
}

@end
