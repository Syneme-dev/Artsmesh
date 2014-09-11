//
//  AMJackDevice.h
//  AMAudio
//
//  Created by 王 为 on 9/8/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMRouteView.h"

@interface AMJackDevice : NSObject

@property NSString* deviceID;
@property NSString* deviceName;
@property NSMutableArray* srcChans;
@property NSMutableArray* desChans;

-(BOOL)addDeviceToRouteView :(AMRouteView*)routeView;

@end
