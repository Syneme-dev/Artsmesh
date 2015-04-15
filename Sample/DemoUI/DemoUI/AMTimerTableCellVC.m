//
//  AMTimerTableCellVC.m
//  DemoUI
//
//  Created by GaoMing on 12/29/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMTimerTableCellVC.h"
#import "AMCoreData/AMCoreData.h"
#import "AMCoreData/AMLiveGroup.h"
#import "AMCoreData/AMLiveUser.h"
#import "AMTimerTabVC.h"
#import "UIFramework/AMPopUpView.h"
#import "UIFramework/AMCheckBoxView.h"
#import "UIFramework/AMFoundryFontView.h"
#import "UIFramework/AMTableCellView.h"

static NSString * const PingCommandFormat =
    @"ping -c 3 -q %@ | tail -1 | awk '{ print $4 }' | awk -F'/' '{ print $2 }'";


@interface AMTimerTableCellVC () <AMPopUpViewDelegeate, AMCheckBoxDelegeate>
@property (weak)            IBOutlet AMPopUpView*       groupPopup;
@property (weak, nonatomic) IBOutlet AMFoundryFontView* bpmLabel;
@property (weak, nonatomic) IBOutlet AMPopUpView*       delayLabel;
@property (weak)            IBOutlet AMPopUpView*       slowdownPopup;
@property (weak, nonatomic) IBOutlet AMFoundryFontView* upperNumber;
@property (weak, nonatomic) IBOutlet AMFoundryFontView* lowNumber;
@property (weak)            IBOutlet AMCheckBoxView*    connectCheckbox;
@property (weak, nonatomic) IBOutlet AMFoundryFontView* metronomeLabel;
@property (nonatomic) NSArray *groups;
@property (nonatomic, readonly) BOOL isOnLine;
@property (nonatomic) BOOL isLocalGroup;
@property (nonatomic) NSTimer *timer;
@property (nonatomic, readonly) NSTimeInterval metronomeTimeInterval;
@end

@implementation AMTimerTableCellVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.groupPopup.delegate = self;
    [self.groupPopup addItemWithTitle:@"----------"];
    [self.groupPopup selectItemAtIndex:0];
    self.slowdownPopup.delegate = self;
    [self.slowdownPopup addItemsWithTitles:@[ @"1", @"1/2", @"1/4", @"1/8", @"1/16", @"1/32" ]];
    [self.slowdownPopup selectItemWithTitle:@"1/4"];
    [self.connectCheckbox setChecked:NO];
    self.connectCheckbox.delegate = self;
    
}

#pragma mark - NSCombofBoxDataSource

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    return self.groups.count + 1;
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
    if (index == 0)
        return @"----------";
    else
        return [self.groups[index - 1] groupName];
}

#pragma mark - AMPopupViewDelegate

- (void)popupViewWillPopup:(AMPopUpView *)popupView
{
    if (popupView == self.groupPopup) {
        self.groups = [[AMCoreData shareInstance] myMergedGroupsInFlat];
        self.isLocalGroup = NO;
        if (!self.groups) {
            self.groups = @[ [[AMCoreData shareInstance] myLocalLiveGroup] ];
            self.isLocalGroup = YES;
        }
        [self.groupPopup removeAllItems];
        NSMutableArray *groupNames = [NSMutableArray array];
        [groupNames addObject:@"----------"];
        [groupNames addObjectsFromArray:[self.groups valueForKeyPath:@"groupName"]];
        [self.groupPopup addItemsWithTitles:groupNames];
    }
}

- (void)itemSelected:(AMPopUpView *)popupView
{
    if (popupView == self.slowdownPopup)
        [self resetTimer];
//    else if (notification.object == self.groupCombox)
//        [self groupDidChange];
}

- (void)groupDidChange
{
    self.delayLabel.stringValue = @"---- ms";
    self.bpmLabel.stringValue = @"60";
    [self resetTimer];
    if (self.isOnLine && self.groupPopup.indexOfSelectedItem > 0) {
        AMLiveGroup *group = self.groups[self.groupPopup.indexOfSelectedItem - 1];
        if ([self groupIsLocal:group])
            return;
        AMLiveUser *user = [group.users lastObject];
        NSString *userIP = user.publicIp;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSTask *task = [[NSTask alloc] init];
            task.launchPath = @"/bin/bash";
            NSString *command = [NSString stringWithFormat:PingCommandFormat, userIP];
            NSLog(@"ping command: %@", command);
            task.arguments = @[@"-c", command];
            NSPipe *pipe = [NSPipe pipe];
            task.standardOutput = pipe;
            [task launch];
            NSData *data = [pipe.fileHandleForReading readDataToEndOfFile];
            NSString *result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            NSLog(@"avg ping time: %@", result);
            double delay = [result floatValue] * 0.5;
            if (delay > 0.0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.delayLabel.stringValue = [NSString stringWithFormat:@"%.3f ms", delay];
                    int bpm = (delay < 10.0) ? 60 : (60000 / delay);
                    self.bpmLabel.stringValue = @(bpm).stringValue;
                    [self resetTimer];
                });
            }
        });
    }
}

- (void)controlTextDidChange:(NSNotification *)notification
{
    if (notification.object == self.lowNumber)
        [self resetTimer];
}

- (void)onChecked:(AMCheckBoxView *)sender
{
    if ([sender checked]) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(startMetronome:)
                                                     name:AMTimerStartNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stopMetronome:)
                                                     name:AMTimerStopNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(pauseMetronome:)
                                                     name:AMTimerPauseNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(resumeMetronome:)
                                                     name:AMTimerResumeNotification
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
    self.metronomeLabel.stringValue = @(1).stringValue;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.metronomeTimeInterval
                                                  target:self
                                                selector:@selector(incrementMetronome)
                                                userInfo:nil
                                                 repeats:YES];
    self.timer.fireDate = notification.userInfo[@"fireDate"];
}

- (void)stopMetronome:(NSNotification *)notification
{
    [self.timer invalidate];
}

- (void)pauseMetronome:(NSNotification *)notification
{
    [self.timer invalidate];
}

- (void)resumeMetronome:(NSNotification *)notification
{
    NSTimeInterval duration = [notification.userInfo[@"Duration"] floatValue];
    NSInteger metronomeValue = ((NSInteger)duration) % self.upperNumber.intValue + 1;
    self.metronomeLabel.stringValue = @(metronomeValue).stringValue;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.metronomeTimeInterval
                                                  target:self
                                                selector:@selector(incrementMetronome)
                                                userInfo:nil
                                                 repeats:YES];
    self.timer.fireDate = [[NSDate date] dateByAddingTimeInterval:1.0];
}

- (void)incrementMetronome
{
    int currentValue = self.metronomeLabel.intValue;
    int maxValue = self.upperNumber.intValue;
    
    if (currentValue >= maxValue)
        currentValue = 1;
    else
        currentValue++;
    
    self.metronomeLabel.stringValue = @(currentValue).stringValue;
}

- (void)resetTimer
{
    if (self.timer.isValid) {
        [self.timer invalidate];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:self.metronomeTimeInterval
                                                      target:self
                                                    selector:@selector(incrementMetronome)
                                                    userInfo:nil
                                                     repeats:YES];
        [self.timer fire];
    }
}

- (NSTimeInterval)metronomeTimeInterval
{
    float timeUnit = self.bpmLabel.stringValue.floatValue / (1 << self.slowdownPopup.indexOfSelectedItem);
    return 60.0 / (timeUnit * self.lowNumber.floatValue);
}

- (BOOL)isOnLine
{
    return [AMCoreData shareInstance].mySelf.isOnline;
}

- (BOOL)groupIsLocal:(AMLiveGroup *)group
{
    NSString *myGroupID = [[AMCoreData shareInstance] myLocalLiveGroup].groupId;
    return [group.groupId isEqualToString:myGroupID];
}

@end
