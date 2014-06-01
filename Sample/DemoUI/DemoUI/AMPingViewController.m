//
//  AMPingViewController.m
//  DemoUI
//
//  Created by 王 为 on 5/5/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMPingViewController.h"
#import "AMPingUserTableCellView.h"
#import "AMMesher/AMMesher.h"
#import "AMMesher/AMUser.h"
#import "AMMesher/AMGroup.h"
#import "AMTaskLauncher/AMShellTask.h"

@interface AMPingViewController ()
{
    AMShellTask *_task;
    NSArray *_users;
}

- (void)runCommand:(NSString *)command;

@end

@implementation AMPingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        _users = [[AMMesher sharedAMMesher] myGroup].users;
        _users = @[[[AMMesher sharedAMMesher] mySelf]];
    }
    
    return self;
}

- (void)awakeFromNib
{
    self.outputTextView.textColor = [NSColor whiteColor];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(userGroupsChanged:)
        name:AM_USERGROUPS_CHANGED
        object:nil];
}

-(void)userGroupsChanged:(NSNotification*)notification
{
    _users = [[AMMesher sharedAMMesher] myGroup].users;
    [self.userTable reloadData];
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter]  removeObserver:self];
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
   
    AMUser* user = _users[row];
    [result.textField setStringValue:user.nickName];
    return result;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    AMUser* user = _users[self.userTable.selectedRow];
    NSString* pingIp = (user.publicIp == nil) ? user.privateIp: user.publicIp;
    NSString *pingCommand = [NSString stringWithFormat:@"ping -c 5 %@",
                                pingIp];
//    [self runCommand:pingCommand];
}

- (void)runCommand:(NSString *)command
{
    if (_task)
        [_task cancel];
    self.outputTextView.string = @"";
    _task = [[AMShellTask alloc] initWithCommand:command];
    [_task launch];
    NSFileHandle *inputStream = [_task fileHandlerForReading];
    NSMutableString *content = [[NSMutableString alloc] init];
    AMPingViewController * __weak weakSelf = self;
    inputStream.readabilityHandler = ^ (NSFileHandle *fh) {
        NSData *data = [fh availableData];
        [content appendString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        AMPingViewController *strongSelf = weakSelf;
        strongSelf.outputTextView.string = content;
    };
}

@end
