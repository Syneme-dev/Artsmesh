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
#import "UIFramework/AMPopUpView.h"

NSString * const AMTimerStartNotification = @"AMTimerStartNotification";
NSString * const AMTimerStopNotification = @"AMTimerStopNotification";
NSString * const AMTimerPauseNotification = @"AMTimerPauseNotification";
NSString * const AMTimerResumeNotification = @"AMTimerResumeNotification";

typedef enum : NSInteger {
    AMTimerCountdownMode,
    AMTimerDurationMode,
    AMTimerRelativeMode,
    AMTimerAbsoluteMode
} AMTimerMode;

typedef enum : NSInteger {
    AMTimerStateStopped,
    AMTimerStateRunning,
    AMTimerStatePaused
} AMTimerState;


@interface AMTimerTabVC () <NSTableViewDataSource, NSTableViewDelegate,
    AMPopUpViewDelegeate>
{
    NSTimeInterval _timeIntervalSettings[4];
    NSTimeInterval _currentCountdownValue;
    NSTimeInterval _currentDurationValue;
}

@property (weak) IBOutlet AMPopUpView *modePopup;

@property (weak) IBOutlet NSTextField *leftHoursTF;
@property (weak) IBOutlet NSTextField *leftMinutesTF;
@property (weak) IBOutlet NSTextField *leftSecondsTF;
@property (nonatomic) NSArray *leftTimeTFs;

@property (weak) IBOutlet NSTextField *rightHoursTF;
@property (weak) IBOutlet NSTextField *rightMinutesTF;
@property (weak) IBOutlet NSTextField *rightSecondsTF;
@property (nonatomic) NSArray *rightTimeTFs;

@property (weak) IBOutlet NSButton *addButton;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) AMTimerState timerState;
@property (weak) IBOutlet NSTableView *tableView;
@property (nonatomic) NSMutableArray *tableCellControllers;
@property (weak) IBOutlet NSButton *playButton;
@property (weak) IBOutlet NSButton *stopButton;
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
    self.timerState = AMTimerStateStopped;
    self.modePopup.delegate = self;
    [self.modePopup addItemsWithTitles:@[ @"Countdown", @"Duration", @"Relative", @"Absolute" ]];
    [self.modePopup selectItemAtIndex:1];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleOSCMessage:)
                                                 name:AM_OSC_NOTIFICATION
                                               object:nil];
}

- (void)handleOSCMessage:(NSNotification *)notification
{
    NSString *event = notification.userInfo[AM_OSC_EVENT_TYPE];
    
    if ([event isEqualToString:AM_OSC_TIMER_STOP]) {
        [self stopTimer:self];
        return;
    }
    
    NSDictionary *stateCheckingTable = @{
         AM_OSC_TIMER_START :   @(AMTimerStateStopped),
         AM_OSC_TIMER_PAUSE :   @(AMTimerStateRunning),
         AM_OSC_TIMER_RESUME :  @(AMTimerStatePaused)
    };
    
    NSNumber *requiredState = stateCheckingTable[event];
    if (requiredState && requiredState.integerValue == self.timerState) {
        [self nextTimerState:self];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AM_OSC_NOTIFICATION object:nil];
}

- (NSTimeInterval)timeInterval:(NSArray *)tfs
{
    return [tfs[0] intValue] * 3600.0 + [tfs[1] intValue] * 60.0 + [tfs[2] intValue];
}

- (void)setTimeInterval:(NSTimeInterval)timeInterval to:(NSArray *)tfs
{
    int hours = timeInterval / 3600.0;
    [tfs[0] setStringValue:[NSString stringWithFormat:@"%02d", hours]];
    timeInterval -= hours * 3600.0;
    int minutes = timeInterval / 60.0;
    [tfs[1] setStringValue:[NSString stringWithFormat:@"%02d", minutes]];
    timeInterval -= minutes * 60.0;
    int seconds = (int)timeInterval;
    [tfs[2] setStringValue:[NSString stringWithFormat:@"%02d", seconds]];
}

- (IBAction)stopTimer:(id)sender
{
    if (self.timer.valid) { // running or pause state
        self.timerState = AMTimerStateStopped;
        self.playButton.title = @"Start";
        if (sender == self.stopButton)
            [[AMOSCGroups sharedInstance] broadcastMessage:AM_OSC_TIMER_STOP
                                                    params:nil];
        [self.timer invalidate];
        [[NSNotificationCenter defaultCenter] postNotificationName:AMTimerStopNotification
                                                            object:self];
    }
}

- (IBAction)nextTimerState:(id)sender
{
    switch (self.timerState) {
    case AMTimerStateStopped:
        self.timerState = AMTimerStateRunning;
        self.playButton.title = @"Pause";
        if (sender == self.playButton)
            [[AMOSCGroups sharedInstance] broadcastMessage:AM_OSC_TIMER_START
                                                    params:nil];
        [self startCountdownTimer];
        break;
            
    case AMTimerStateRunning:
        self.timerState = AMTimerStatePaused;
        self.playButton.title = @"Resume";
        if (sender == self.playButton)
            [[AMOSCGroups sharedInstance] broadcastMessage:AM_OSC_TIMER_PAUSE
                                                    params:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:AMTimerPauseNotification
                                                            object:self
                                                          userInfo:nil];
        [self.timer invalidate];
        break;
            
    case AMTimerStatePaused:
        self.timerState = AMTimerStateRunning;
        self.playButton.title = @"Pause";
        if (sender == self.playButton)
            [[AMOSCGroups sharedInstance] broadcastMessage:AM_OSC_TIMER_RESUME
                                                    params:nil];
            
        _currentDurationValue = [self timeInterval:self.leftTimeTFs];
        [[NSNotificationCenter defaultCenter] postNotificationName:AMTimerResumeNotification
                                                            object:self
                                                          userInfo:@{ @"Duration" : @(_currentDurationValue) }];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(incrementTimerLabel)
                                                    userInfo:nil
                                                     repeats:YES];
        self.timer.fireDate = [[NSDate date] dateByAddingTimeInterval:1.0];
        break;
    }
}

- (void)startCountdownTimer
{
    _currentCountdownValue = _timeIntervalSettings[AMTimerCountdownMode];
    _arrowLabel.stringValue = @"↓";
    [self setTimeInterval:_currentCountdownValue to:self.leftTimeTFs];
    
    time_t t = time(NULL);
    struct tm loc = *localtime(&t);
    loc.tm_hour = 0;
    loc.tm_min = 0;
    loc.tm_sec = 0;
    t = mktime(&loc);
    NSTimeInterval startTimeByAbsoluteSetting = t + _timeIntervalSettings[AMTimerAbsoluteMode];
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    
    if (now <= startTimeByAbsoluteSetting) {
        self.playButton.enabled = NO;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(decrementTimerLabel)
                                                    userInfo:nil
                                                     repeats:YES];
        self.timer.fireDate = [NSDate dateWithTimeIntervalSince1970:startTimeByAbsoluteSetting + 1.0];
    } else if (_currentCountdownValue > 0) {
        self.playButton.enabled = NO;
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
        [self setTimeInterval:0.0 to:self.leftTimeTFs];
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
        self.timerState = AMTimerStateStopped;
        self.playButton.title = @"Start";
    }
}

- (void)decrementTimerLabel
{
    _currentCountdownValue = MAX(_currentCountdownValue - 1.0, 0.0);
    [self setTimeInterval:_currentCountdownValue to:self.leftTimeTFs];
    if (_currentCountdownValue <= 0.0) {
        [self.timer invalidate];
        self.playButton.enabled = YES;
        [self startDurationTimer];
    }
}

- (void)incrementTimerLabel
{
    _currentDurationValue += 1.0;
    [self setTimeInterval:_currentDurationValue to:self.leftTimeTFs];
    if (_currentDurationValue >= _timeIntervalSettings[AMTimerDurationMode]) {
        [self stopTimer:self];
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

- (void)itemSelected:(AMPopUpView *)sender
{
    NSTimeInterval timeInterval = _timeIntervalSettings[self.modePopup.indexOfSelectedItem];
    [self setTimeInterval:timeInterval to:self.rightTimeTFs];
}

- (void)controlTextDidChange:(NSNotification *)notification
{
    if ([self.rightTimeTFs indexOfObjectIdenticalTo:notification.object] != NSNotFound) {
        NSTimeInterval timeInterval = [self timeInterval:self.rightTimeTFs];
        NSInteger mode = self.modePopup.indexOfSelectedItem;
        _timeIntervalSettings[mode] = timeInterval;
    }
}

- (NSArray *)leftTimeTFs
{
    if (!_leftTimeTFs) {
        _leftTimeTFs = @[ self.leftHoursTF, self.leftMinutesTF, self.leftSecondsTF ];
    }
    return _leftTimeTFs;
}

- (NSArray *)rightTimeTFs
{
    if (!_rightTimeTFs) {
        _rightTimeTFs = @[ self.rightHoursTF, self.rightMinutesTF, self.rightSecondsTF ];
    }
    return _rightTimeTFs;
}

@end
