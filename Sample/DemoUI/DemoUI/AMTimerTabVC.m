//
//  AMTimerTabVC.m
//  DemoUI
//
//  Created by robbin on 14/12/15.
//  Copyright (c) 2014年 Artsmesh. All rights reserved.
//

#import "AMTimerTabVC.h"
#import "AMTimerTableCellVC.h"

NSString * const AMTimerStartNotification = @"AMTimerStartNotification";
NSString * const AMTimerStopNotification = @"AMTimerStopNotification";

static const NSInteger MaxNumberOfMetronomes = 10;

@interface AMTimerTabVC () <NSTableViewDataSource, NSTableViewDelegate,
    NSComboBoxDataSource, NSComboBoxDelegate>
@property (weak) IBOutlet NSButton *addButton;
@property (weak) IBOutlet NSTextField *timerLabel;
@property (nonatomic) NSTimer *timer;
@property (nonatomic) NSDate *timerStartDate;
@property (weak) IBOutlet NSTableView *tableView;
@property (nonatomic) NSMutableArray *tableCellControllers;
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
}

- (IBAction)toggleTimer:(id)sender
{
    if (self.timer.valid) {
        [self.timer invalidate];
        [[NSNotificationCenter defaultCenter] postNotificationName:AMTimerStopNotification
                                                            object:self];
    } else {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(updateTimerLabel)
                                                    userInfo:nil
                                                     repeats:YES];
        self.timerStartDate = [NSDate date];
        [self.timer fire];
        [[NSNotificationCenter defaultCenter] postNotificationName:AMTimerStartNotification
                                                            object:self];
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

@end
