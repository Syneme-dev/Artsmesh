//
//  AMTimerTableCellView.m
//  DemoUI
//
//  Created by robbin on 14/12/15.
//  Copyright (c) 2014年 Artsmesh. All rights reserved.
//

#import "AMTimerTableCellView.h"
#import "AMTimerTabVC.h"

@interface AMTimerTableCellView () <NSComboBoxDelegate>
@property (nonatomic, readonly) NSTimeInterval timeInterval;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSInteger maxValue;
@property (nonatomic) NSInteger currentValue;
@end

@implementation AMTimerTableCellView

- (NSTimeInterval)timeInterval
{
    float timeUnit = self.bpmLabel.stringValue.floatValue / (1 << self.slowdownCombox.indexOfSelectedItem);
    return 60.0 / timeUnit * self.lowNumber.floatValue;
}

- (IBAction)toogleLockState:(NSButton *)sender
{
    if (sender.state == NSOnState) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(startMetronome:)
                                                     name:AMTimerStartNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stopMetronome:)
                                                     name:AMTimerStopNotification
                                                   object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)startMetronome:(NSNotification *)notification
{
    self.currentValue = 0;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval
                                                  target:self
                                                selector:@selector(updateMetronome)
                                                userInfo:nil
                                                 repeats:YES];
    [self.timer fire];
    self.lockButton.enabled = NO;
}

- (void)setUpperNumber:(NSTextField *)upperNumber
{
    _upperNumber = upperNumber;
    self.maxValue = _upperNumber.stringValue.integerValue;
}

- (void)updateMetronome
{
    if (self.currentValue >= self.maxValue)
        self.currentValue = 1;
    else
        self.currentValue++;
    
    self.metronomeLabel.stringValue = @(self.currentValue).stringValue;
}

- (void)stopMetronome:(NSNotification *)notification
{
    [self.timer invalidate];
    self.lockButton.enabled = YES;
}

- (void)updateMetronomeParameters
{
    if (self.timer.isValid) {
        [self.timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval
                                                      target:self
                                                    selector:@selector(updateMetronome)
                                                    userInfo:nil
                                                     repeats:YES];
        [self.timer fire];
    }
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
    [self updateMetronomeParameters];
}

- (void)controlTextDidChange:(NSNotification *)notification
{
    if (notification.object == self.upperNumber)
        self.maxValue = self.upperNumber.stringValue.integerValue;
    else if (notification.object == self.lowNumber)
        [self updateMetronomeParameters];
}

@end
