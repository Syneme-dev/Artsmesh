//
//  AMJackTripManager.h
//  AMAudio
//
//  Created by 王 为 on 9/10/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMTaskLauncher/AMShellTask.h"
#import "AMJacktripConfigs.h"

@interface AMJacktripInstance : NSObject

@property NSString* instanceName;
@property AMShellTask* jacktripTask;
@property int portOffset;
@property int channelCount;

@end

@interface AMJackTripManager : NSObject

@property NSMutableArray* jackTripInstances;

-(BOOL)startJacktrip:(AMJacktripConfigs*)cfgs;
-(void)stopAllJacktrips;
-(void)stopJacktripByName:(NSString*)instanceName;

@end
