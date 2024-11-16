//
//  QTKitHelper.h
//  SyphonCamera
//
//  Created by Normen Hansen on 20.05.12.
//  Copyright (c) 2012 Normen Hansen. Released under New BSD license.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AVFWrapper : NSObject
//get a array of all AVF video devices
+(NSArray *) getAVVideoDeviceList;

//gets a video device by name
+(AVCaptureDevice*) getAVVideoDeviceWithName:(NSString*)name;

//disables audio for a muxed video device
+ (void)disableAVAudioForInput:(AVCaptureDeviceInput *)input;

@end
