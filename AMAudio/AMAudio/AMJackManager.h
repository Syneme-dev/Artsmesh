//
//  AMJackManager.h
//  AMAudio
//
//  Created by 王 为 on 9/10/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    JackState_Stopped = 0,
    JackState_Started,
}JackState;

@interface AMJackManager : NSObject

@property  JackState jackState;

-(BOOL)startJack;
-(void)stopJack;

@end
