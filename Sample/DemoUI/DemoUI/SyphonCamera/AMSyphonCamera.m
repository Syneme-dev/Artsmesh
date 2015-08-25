//
//  SCAppDelegate.m
//  SyphonCamera
//
//  Created by Normen Hansen on 19.05.12.
//  Copyright (c) 2012 Normen Hansen. Released under New BSD license.
//

#import "AMSyphonCamera.h"

NSString* faceTimeCamera = @"FaceTime HD Camera";
@implementation AMSyphonCamera

- (id)init
{
    self = [super init];
    if(self){
        _selectedDevice = -1;
        runningDevices = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (void) startDevice:(NSString*)name{
    if([runningDevices objectForKey:name]!=nil){
        return;
    }
    SyphonSender *sender = [[SyphonSender alloc] init];
    sender.deviceName = name;
    sender.enabled = YES;
    [runningDevices setObject:sender forKey:name];
}

- (void) stopDeviceWithName:(NSString*)name{
    SyphonSender *sender = [runningDevices objectForKey:name];
    sender.enabled = NO;
    [runningDevices removeObjectForKey:name];
}

- (void) initializeDevices
{
    NSArray *devices = [QTKitHelper getVideoDeviceList];
    
    for (NSInteger i=0; i < devices.count; i++) {
        QTCaptureDevice *mydevice = [devices objectAtIndex:i];
        if([mydevice.description isEqualToString:faceTimeCamera]){
            [self startDevice:mydevice.description];
        }
    }
}

- (void)setSelectedDevice:(NSIndexSet *)selectedCam {
    
    NSArray *devices = [QTKitHelper getVideoDeviceList];
    
    QTCaptureDevice *mydevice = [devices objectAtIndex:_selectedDevice];
    selectedDeviceName = mydevice.description;
    
}

- (NSIndexSet *)selectedDevice{
    if(_selectedDevice < 0){
        return [NSIndexSet indexSet];
    }
    return [NSIndexSet indexSetWithIndex:_selectedDevice];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSArray *devices = [QTKitHelper getVideoDeviceList];
    if(devices.count > row){
        return [[devices objectAtIndex:row] description];
    }
    return @"?";
}

@end
