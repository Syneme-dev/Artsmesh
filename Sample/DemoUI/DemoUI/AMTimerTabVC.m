//
//  AMTimerTabVC.m
//  DemoUI
//
//  Created by robbin on 14/12/15.
//  Copyright (c) 2014年 Artsmesh. All rights reserved.
//

#import "AMTimerTabVC.h"
#import "AMTimerTableCellVC.h"
#import "AMOSCGroups/AMOSCGroups.h"
#import "AMOSCGroups/AMOSCDefine.h"

NSString * const AMTimerStartNotification = @"AMTimerStartNotification";
NSString * const AMTimerStopNotification = @"AMTimerStopNotification";

typedef enum : NSInteger {
    AMTimerCountdownMode,
    AMTimerDurationMode,
    AMTimerRelativeMode,
    AMTimerAbsoluteMode
} AMTimerMode;


@interface AMTimerTabVC () <NSTableViewDataSource, NSTableViewDelegate,
    NSComboBoxDelegate>
{
    NSTimeInterval _timeIntervalSettings[4];
    NSTimeInterval _currentCountdownValue;
    NSTimeInterval _currentDurationValue;
}

@property (weak) IBOutlet NSComboBox *modeComboBox;
@property (weak) IBOutlet NSTextField *hoursTextField;
@property (weak) IBOutlet NSTextField *minutesTextField;
@property (weak) IBOutlet NSTextField *secondsTextField;
@property (nonatomic) NSTimeInterval timeInterval;
@property (weak) IBOutlet NSButton *addButton;
@property (weak) IBOutlet NSTextField *timerLabel;
@property (nonatomic) NSTimer *timer;
@property (weak) IBOutlet NSTableView *tableView;
@property (nonatomic) NSMutableArray *tableCellControllers;
@property (weak) IBOutlet NSButton *playButton;
@property (weak) IBOutlet NSTextField *arrowLabel;
@end

@implementation AMTimerTabVC

- (void)viewDidLoad
{
    [self addTableCellController:nil];
    NSMutableAttributedString *attributedTitle = [self.addButton.attributedTitle mutableCopy];
    [attributedTitle addAttribute:NSForegroundColorAttributeName
                            value:[NSColor lightGrayColor]
                            range:NSMakeRange(0, attributedTitle.length)];
    self.addButton.attributedTitle = attributedTitle;
    [self.modeComboBox selectItemAtIndex:1];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleOSCMessage:)
                                                 name:AM_OSC_NOTIFICATION
                                               object:nil];
}

- (void)handleOSCMessage:(NSNotification *)notification
{
    NSString *event = notification.userInfo[AM_OSC_EVENT_TYPE];
    if ([event isEqualToString:AM_OSC_TIMER_START] && self.playButton.state == NSOffState) {
        [self.playButton performClick:self];
    } else if ([event isEqualToString:AM_OSC_TIMER_STOP] && self.playButton.state == NSOnState) {
        [self.playButton performClick:self];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AM_OSC_NOTIFICATION object:nil];
}

- (NSTimeInterval)timeInterval
{
    return self.hoursTextField.intValue * 3600.0 + self.minutesTextField.intValue * 60.0 +
            self.secondsTextField.intValue;
}

- (void)setTimeInterval:(NSTimeInterval)timeInterval
{
    int hours = timeInterval / 3600.0;
    self.hoursTextField.stringValue = [NSString stringWithFormat:@"%02d", hours];
    timeInterval -= hours * 3600.0;
    int minutes = timeInterval / 60.0;
    self.minutesTextField.stringValue = [NSString stringWithFormat:@"%02d", minutes];
    timeInterval -= minutes * 60.0;
    int seconds = (int)timeInterval;
    self.secondsTextField.stringValue = [NSString stringWithFormat:@"%02d", seconds];
}

- (IBAction)toggleTimer:(id)sender
{
    if (self.timer.valid) {
        [[AMOSCGroups sharedInstance] broadcastMessage:AM_OSC_TIMER_STOP
                                                params:nil];
        [self.timer invalidate];
        [[NSNotificationCenter defaultCenter] postNotificationName:AMTimerStopNotification
                                                            object:self];
    } else {
        [[AMOSCGroups sharedInstance] broadcastMessage:AM_OSC_TIMER_START
                                                params:nil];
        [self startCountdownTimer];
    }
}

- (void)startCountdownTimer
{
    _currentCountdownValue = _timeIntervalSettings[AMTimerCountdownMode];
    _arrowLabel.stringValue = @"↓";
    [self setTimerLabelByInterval:_currentCountdownValue];
    
    time_t t = time(NULL);
    struct tm loc = *localtime(&t);
    loc.tm_hour = 0;
    loc.tm_min = 0;
    loc.tm_sec = 0;
    t = mktime(&loc);
    NSTimeInterval startTimeByAbsoluteSetting = t + _timeIntervalSettings[AMTimerAbsoluteMode];
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    
    if (now <= startTimeByAbsoluteSetting) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(decrementTimerLabel)
                                                    userInfo:nil
                                                     repeats:YES];
        self.timer.fireDate = [NSDate dateWithTimeIntervalSince1970:startTimeByAbsoluteSetting + 1.0];
    } else if (_currentCountdownValue > 0) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(decrementTimerLabel)
                                                    userInfo:nil
                                                     repeats:YES];
        self.timer.fireDate = [[NSDate date] dateByAddingTimeInterval:1.0];
    } else {
        [self startDurationTimer];
    }
}

- (void)startDurationTimer
{
    _currentDurationValue = 0.0;
    _arrowLabel.stringValue = @"↑";
    if (_timeIntervalSettings[AMTimerDurationMode] > 0.0) {
        [self setTimerLabelByInterval:0.0];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(incrementTimerLabel)
                                                    userInfo:nil
                                                     repeats:YES];
        
        NSDate *fireDate = [[NSDate date] dateByAddingTimeInterval:1.0];
        self.timer.fireDate = fireDate;
        [[NSNotificationCenter defaultCenter] postNotificationName:AMTimerStartNotification
                                                            object:self
                                                          userInfo:@{ @"fireDate" : fireDate }];
    } else {
        self.playButton.state = NSOffState;
    }
}

- (void)setTimerLabelByInterval:(NSTimeInterval)timeInterval
{
    int hours = timeInterval / 3600.0;
    timeInterval -= hours * 3600.0;
    hours %= 100;
    int minutes = timeInterval / 60.0;
    timeInterval -= minutes * 60.0;
    int seconds = (int)timeInterval;
    NSString *text = [NSString stringWithFormat:@"%02d : %02d : %02d", hours, minutes, seconds];
    self.timerLabel.stringValue = text;
}

- (void)decrementTimerLabel
{
    _currentCountdownValue = MAX(_currentCountdownValue - 1.0, 0.0);
    [self setTimerLabelByInterval:_currentCountdownValue];
    if (_currentCountdownValue <= 0.0) {
        [self.timer invalidate];
        [self startDurationTimer];
    }
}

- (void)incrementTimerLabel
{
    _currentDurationValue += 1.0;
    [self setTimerLabelByInterval:_currentDurationValue];
    if (_currentDurationValue >= _timeIntervalSettings[AMTimerDurationMode]) {
        [self.playButton performClick:self];
    }
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.tableCellControllers.count;
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row
{
    return [self.tableCellControllers[row] view];
}

- (NSMutableArray *)tableCellControllers
{
    if (!_tableCellControllers)
        _tableCellControllers = [NSMutableArray array];
    return _tableCellControllers;
}

- (IBAction)addTableCellController:(id)sender
{
    AMTimerTableCellVC *vc = [[AMTimerTableCellVC alloc] initWithNibName:@"AMTimerTableCellVC" bundle:nil];
    [self.tableCellControllers addObject:vc];
    [self.tableView reloadData];
    [self.tableView scrollRowToVisible:self.tableCellControllers.count - 1];
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
    self.timeInterval = _timeIntervalSettings[self.modeComboBox.indexOfSelectedItem];
}

- (void)controlTextDidChange:(NSNotification *)notification
{
    NSTimeInterval timeInterval = self.timeInterval;
    NSInteger mode = self.modeComboBox.indexOfSelectedItem;
    _timeIntervalSettings[mode] = timeInterval;
}

@end
