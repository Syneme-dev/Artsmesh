//
//  AMTimerTabVC.m
//  DemoUI
//
//  Created by robbin on 14/12/15.
//  Copyright (c) 2014年 Artsmesh. All rights reserved.
//

#import "AMTimerTabVC.h"
#import "AMTimerTableCellView.h"
#import "AMCoreData/AMCoreData.h"
#import "AMCoreData/AMLiveGroup.h"
#import "AMCoreData/AMLiveUser.h"

static NSString * const PingCommandFormat =
    @"ping -c 3 -q %@ | tail -1 | awk '{ print $4 }' | awk -F'/' '{ print $2 }'";
static NSString * const DummyGroupName = @"----------";

@interface AMTimerTabVC () <NSTableViewDataSource, NSTableViewDelegate,
    NSComboBoxDataSource, NSComboBoxDelegate>
@property (weak) IBOutlet NSTextField *timerLabel;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSDate *timerStartDate;
@property (nonatomic) BOOL isLocalGroup;
@property (nonatomic) NSArray *groups;
@end

@implementation AMTimerTabVC

- (void)reloadGroups:(NSNotification *)notification
{
    self.groups = [[AMCoreData shareInstance] myMergedGroupsInFlat];
}

- (IBAction)toggleTimer:(id)sender
{
    if (self.timer.valid) {
        [self.timer invalidate];
    } else {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(updateTimerLabel)
                                                    userInfo:nil
                                                     repeats:YES];
        self.timerStartDate = [NSDate date];
        [self.timer fire];
    }
}

- (void)updateTimerLabel
{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.timerStartDate];
    int hours = timeInterval / 3600.0;
    timeInterval -= hours * 3600.0;
    hours %= 100;
    int minutes = timeInterval / 60.0;
    int seconds = timeInterval - minutes * 60.0;
    
    NSString *text = [NSString stringWithFormat:@"%02d : %02d : %02d", hours, minutes, seconds];
    self.timerLabel.stringValue = text;
}

- (NSInteger)numberOfItemsInComboBox:(NSComboBox *)aComboBox
{
    return self.groups.count + 1;
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
    if (index == 0)
        return DummyGroupName;
    else
        return [self.groups[index - 1] groupName];
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
    NSComboBox *comboBox = (NSComboBox *)notification.object;
    AMTimerTableCellView *cell = (AMTimerTableCellView *)comboBox.superview;
    cell.delayLabel.stringValue = @"---- ms";
    NSInteger index = comboBox.indexOfSelectedItem;
    if (index != 0) {
        AMLiveGroup *group = self.groups[index - 1];
        AMLiveUser *user = [group.users lastObject];
        NSString *userIP = self.isLocalGroup ? user.privateIp : user.publicIp;
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
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.delayLabel.stringValue = [NSString stringWithFormat:@"%.3f ms", delay];
            });
        });
    }
}

- (void)comboBoxWillPopUp:(NSNotification *)notification
{
    self.groups = [[AMCoreData shareInstance] myMergedGroupsInFlat];
    self.isLocalGroup = NO;
    if (!self.groups) {
        self.groups = @[ [[AMCoreData shareInstance] myLocalLiveGroup] ];
        self.isLocalGroup = YES;
    }
    NSComboBox *combox = (NSComboBox *)notification.object;
    [combox reloadData];
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return 2;
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row
{
    AMTimerTableCellView *cell = [tableView makeViewWithIdentifier:@"AMTimerTableCellView" owner:self];
    [cell.groupCombox selectItemAtIndex:0];
    return cell;
}

@end
