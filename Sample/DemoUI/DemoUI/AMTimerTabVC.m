//
//  AMTimerTabVC.m
//  DemoUI
//
//  Created by robbin on 14/12/15.
//  Copyright (c) 2014年 Artsmesh. All rights reserved.
//

#import "AMTimerTabVC.h"

@interface AMTimerTabVC ()
@property (weak) IBOutlet NSTextField *timerLabel;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSTimeInterval timerStartTime;
@end

@implementation AMTimerTabVC

- (IBAction)toggleTimer:(id)sender
{
    if (self.timer.valid)
        [self.timer invalidate];
    else
        [self.timer fire];
}


- (NSTimer *)timer
{
    if (!_timer.valid) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                  target:self
                                                selector:@selector(updateTimerLabel)
                                                userInfo:nil
                                                 repeats:YES];
    }
    return _timer;
}

- (void)updateTimerLabel
{
    NSTimeInterval timeInterval = [self.timer.fireDate timeIntervalSinceNow];
    int seconds = fmod(timeInterval, 60.0);
    int minutes = fmod(timeInterval, 3600.0);
    int hours = fmod(timeInterval, 360000.0);
    NSString *text = [NSString stringWithFormat:@"%02d : %02d : %02d", hours, minutes, seconds];
    self.timerLabel.stringValue = text;
}

@end
