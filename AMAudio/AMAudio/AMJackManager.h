//
//  AMJackManager.h
//  AMAudio
//
//  Created by 王 为 on 9/10/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMJackConfigs.h"
#import "AMAudio.h"

@interface AMJackManager : NSObject

@property  JackState jackState;
@property  AMJackConfigs* jackCfg;

-(BOOL)startJack;
-(void)stopJack;

@end
