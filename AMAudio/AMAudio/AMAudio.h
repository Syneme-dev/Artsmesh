//
//  AMAudio.h
//  AMAudio
//
//  Created by 王 为 on 8/22/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMAudioDevice.h"
#import "AMAudioDeviceManager.h"

typedef enum {
    JackState_Stopped = 0,
    JackState_Started,
}JackState;

@interface AMAudio : NSObject

@property (readonly) JackState jackState;

+(id)sharedInstance;

-(NSViewController*)getJackPrefUI;
-(BOOL)startJack;
-(void)stopJack;

@end
