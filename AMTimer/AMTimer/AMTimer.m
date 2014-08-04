//
//  AMTimer.m
//  AMTimer
//
//  Created by Wei Wang on 8/1/14.
//  Copyright (c) 2014 Wei Wang. All rights reserved.
//

#import "AMTimer.h"
#import "MZTimerLabel.h"

@implementation AMTimer
{
    MZTimerLabel* _mztimer;
}

+(AMTimer*)shareInstance
{
    static AMTimer* sharedInstance = nil;
    @synchronized(self){
        if (sharedInstance == nil){
            sharedInstance = [[self alloc] privateInit];
        }
    }
    return sharedInstance;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:NSInvalidArgumentException
                                   reason:@"unsupported initializer"
                                 userInfo:nil];
}

-(AMTimer*)privateInit
{
    _mztimer =  [[MZTimerLabel alloc] init];
    _mztimer.timerType = MZTimerLabelTypeStopWatch;
    [_mztimer setStopWatchTime:0];
    _mztimer.timeFormat = @"HH:mm:ss";
    
    self.state = kAMTimerStop;

    return self;
}

-(void)start
{
    [_mztimer start];
    self.state = kAMTimerStart;
}

-(void)pause
{
    [_mztimer pause];
    self.state = kAMTimerPause;
}

-(void)reset
{
    [_mztimer reset];
    self.state = kAMTimerStop;
}

-(void)addTimerScreen:(NSTextField*) screen
{
    [_mztimer addTimerScreen:screen];
}

-(void)removeTimerScreen:(NSTextField*)timeLabel
{
    [_mztimer removeTimerScreen:timeLabel];
}

-(void)removeAllScreen
{
    [_mztimer removeAllScreen];
}

@end
