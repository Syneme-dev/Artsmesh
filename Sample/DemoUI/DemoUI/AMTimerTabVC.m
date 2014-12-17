//
//  AMTimerTabVC.m
//  DemoUI
//
//  Created by robbin on 14/12/15.
//  Copyright (c) 2014年 Artsmesh. All rights reserved.
//

#import "AMTimerTabVC.h"
#import "AMTimerTableCellView.h"

// ping -c 3 -q localhost | tail -1 | awk '{ print $4 }' | awk -F"/" '{ print $2 }'

@interface AMTimerTabVC () <NSTableViewDataSource, NSTableViewDelegate, NSComboBoxDataSource>
@property (weak) IBOutlet NSTextField *timerLabel;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSDate *timerStartDate;
@property (weak) IBOutlet NSComboBox *groupCombox;
@end

@implementation AMTimerTabVC

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
    return 3;
}

- (id)comboBox:(NSComboBox *)aComboBox objectValueForItemAtIndex:(NSInteger)index
{
    return [NSString stringWithFormat:@"GROUP %ld", index];
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
