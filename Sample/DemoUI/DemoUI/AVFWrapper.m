//
//  QTKitHelper.m
//  SyphonCamera
//
//  Created by Normen Hansen on 20.05.12.
//  Copyright (c) 2012 Normen Hansen. Released under New BSD license.
//

#import "AVFWrapper.h"

@implementation AVFWrapper
+(NSArray *) getAVVideoDeviceList
{
    NSArray *videoDevices= [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    NSArray *muxedDevices= [AVCaptureDevice devicesWithMediaType:AVMediaTypeMuxed];
    
    NSMutableArray *mutableArrayOfDevice = [[NSMutableArray alloc] init ];
    [mutableArrayOfDevice addObjectsFromArray:videoDevices];
    [mutableArrayOfDevice addObjectsFromArray:muxedDevices];
    
    NSArray *devices = [NSArray arrayWithArray:mutableArrayOfDevice];
    return devices;
}




+ (AVCaptureDevice *)getAVVideoDeviceWithName:(NSString *)name{
    NSArray *devices = [AVFWrapper getAVVideoDeviceList];
    AVCaptureDevice *device = nil;
    for (NSInteger i=0; i < devices.count; i++) {
        AVCaptureDevice *mydevice = [devices objectAtIndex:i];
        if([mydevice.localizedName isEqualToString:name]){
            device = mydevice;
        }
    }
    return device;
}

+ (void)disableAVAudioForInput:(AVCaptureDeviceInput *)input{
/*    NSArray *muxedDevices= [AVCaptureDevice devicesWithMediaType:AVMediaTypeMuxed];
    if ([muxedDevices containsObject:input.device]) {
        NSArray *ownedConnections = [input connections];
        for (AVCaptureConnection *connection in ownedConnections) {
            if ( [[connection mediaType] isEqualToString:AVMediaTypeAudio]) {
                [connection setEnabled:NO];
            }
        }
    }*/
}

@end
