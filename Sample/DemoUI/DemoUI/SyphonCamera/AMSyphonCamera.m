//
//  SCAppDelegate.m
//  SyphonCamera
//
//  Created by Normen Hansen on 19.05.12.
//  Copyright (c) 2012 Normen Hansen. Released under New BSD license.
//

#import "AMSyphonCamera.h"
#import "AMSyphonManager.h"

@implementation AMSyphonCamera

- (id)init
{
    if(self = [super init]){
        runningDevices = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (void) startDevice:(NSString*)name{
    if([runningDevices objectForKey:name]!=nil){
        return;
    }
    AMSyphonSender *sender = [[AMSyphonSender alloc] init];
    sender.deviceName = name;
    sender.enabled = YES;
    [runningDevices setObject:sender forKey:name];
}

- (void) stopDeviceWithName:(NSString*)name{
    if([runningDevices objectForKey:name]!=nil){
        return;
    }
    
    AMSyphonSender *sender = [runningDevices objectForKey:name];
    sender.enabled = NO;
    [runningDevices removeObjectForKey:name];
}

- (void) initializeDevice
{
    NSArray *devices = [AVFWrapper getAVVideoDeviceList];
    
    for (NSInteger i=0; i < devices.count; i++) {
        AVCaptureDevice *mydevice = [devices objectAtIndex:i];
        if([AMSyphonName isSyphonCamera:mydevice.localizedName]){
            [self startDevice:mydevice.localizedName];
        }
    }
}

@end
