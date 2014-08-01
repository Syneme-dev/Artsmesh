//
//  AMTimer.h
//  AMTimer
//
//  Created by Wei Wang on 8/1/14.
//  Copyright (c) 2014 Wei Wang. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum{
    kAMTimerStop,
    kAMTimerPause,
    kAMTimerStart,
}AMTimerState;


@interface AMTimer : NSObject

+(AMTimer*)shareInstance;

@property AMTimerState state;

-(void)addTimerScreen:(NSTextField*) screen;
-(void)removeTimerScreen:(NSTextField*)timeLabel;
-(void)removeAllScreen;

-(void)start;
-(void)pause;
-(void)reset;

@end
