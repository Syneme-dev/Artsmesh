//
//  AMNetworkToolsViewController.m
//  DemoUI
//
//  Created by lattesir on 8/5/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMNetworkToolsViewController.h"
#import <UIFramework/AMButtonHandler.h>
#import "AMCoreData/AMCoreData.h"
#import "AMNetworkToolsCommand.h"

@interface AMNetworkToolsViewController ()
{
    NSArray *_users;
    AMNetworkToolsCommand *_pingCommand;
    AMNetworkToolsCommand *_tracerouteCommand;
}

@end

@implementation AMNetworkToolsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [AMButtonHandler changeTabTextColor:self.pingButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.tracerouteButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.iperfButton toColor:UI_Color_blue];
    
    _pingCommand = [[AMNetworkToolsCommand alloc] init];
    _pingCommand.contentView = self.pingContentView;
    
    _tracerouteCommand = [[AMNetworkToolsCommand alloc] init];
    _tracerouteCommand.contentView = self.tracerouteContentView;
    
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(userGroupsChanged:)
        name: AM_LIVE_GROUP_CHANDED
        object:nil];
}

-(void)registerTabButtons
{
    super.tabs=self.tabs;
    self.tabButtons =[[NSMutableArray alloc]init];
    [self.tabButtons addObject:self.pingButton];
    [self.tabButtons addObject:self.tracerouteButton];
    [self.tabButtons addObject:self.iperfButton];
    self.showingTabsCount=3;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
}

-(void)userGroupsChanged:(NSNotification*)notification
{
    AMLiveGroup* mergedGroup = [[AMCoreData shareInstance] mergedGroup];
    _users = [mergedGroup usersIncludeSubGroup];
    
    [self.pingTableView reloadData];
    [self.tracerouteTableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_users count];
}

- (id)tableView:(NSTableView *)tableView
viewForTableColumn:(NSTableColumn *)tableColumn
            row:(NSInteger)row
{
    
    NSTableCellView *result = [tableView makeViewWithIdentifier:tableColumn.identifier
                                                          owner:nil];
    AMLiveUser* user = _users[row];
    [result.textField setStringValue:user.nickName];
    return result;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSTableView *tableView = notification.object;
    if (tableView.selectedRow == -1)
        return;
    AMLiveUser* user = _users[tableView.selectedRow];
    NSString* ip = user.publicIp;
    if (tableView == self.pingTableView) {
        NSString *command = [NSString stringWithFormat:@"ping -c 5 %@", ip];
        [_pingCommand stop];
        _pingCommand.command = command;
        [_pingCommand run];
    } else if (tableView == self.tracerouteTableView) {
        NSString *command = [NSString stringWithFormat:@"/usr/sbin/traceroute %@", ip];
        [_tracerouteCommand stop];
        _tracerouteCommand.command = command;
        [_tracerouteCommand run];
    }
}

- (IBAction)ping:(id)sender
{
    [self.tabView selectTabViewItemWithIdentifier:@"pingTab"];
}

- (IBAction)traceroute:(id)sender
{
    [self.tabView selectTabViewItemWithIdentifier:@"tracerouteTab"];
}

- (IBAction)iperf:(id)sender
{
    [self.tabView selectTabViewItemWithIdentifier:@"iperfTab"];
}

@end
