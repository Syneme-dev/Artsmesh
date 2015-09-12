//
//  SCAppDelegate.h
//  SyphonCamera
//
//  Created by Normen Hansen on 19.05.12.
//  Copyright (c) 2012 Normen Hansen. Released under New BSD license.
//

#import <Cocoa/Cocoa.h>
#import "QTKitHelper.h"
#import "SyphonSender.h"

@interface AMSyphonCamera : NSObject {
    
    NSInteger _selectedDevice;
    NSString *selectedDeviceName;
    NSMutableDictionary *runningDevices;
}

- (void) initializeDevice;

@end
