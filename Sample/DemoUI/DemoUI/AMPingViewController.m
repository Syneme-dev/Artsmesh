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
#import "AMMesher/AMAppObjects.h"
#import "AMMesher/AMGroup.h"
#import "AMTaskLauncher/AMShellTask.h"

#define UI_Color_b7b7b7  [NSColor colorWithCalibratedRed:(168)/255.0f green:(168)/255.0f blue:(168)/255.0f alpha:1.0f]

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
       // _users = [[AMMesher sharedAMMesher] myGroup].users;
    }
    
    return self;
}

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(userGroupsChanged:)
        name:AM_REMOTEGROUPS_CHANGED
        object:nil];
}

-(void)userGroupsChanged:(NSNotification*)notification
{
    NSString *mergedGroupId = [AMAppObjects appObjects][AMMergedGroupIdKey];
    NSDictionary *groups = [AMAppObjects appObjects][AMRemoteGroupsKey];
    _users = [groups[mergedGroupId] users];
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
    if (self.userTable.selectedRow == -1)
        return;
    AMUser* user = _users[self.userTable.selectedRow];
    NSString* pingIp = user.ip;
    NSString *pingCommand = [NSString stringWithFormat:@"ping -c 5 %@",
                                pingIp];
    [self runCommand:pingCommand];
}

- (void)runCommand:(NSString *)command
{
    if (_task)
        [_task cancel];
    NSTextView *outputView = self.outputTextView;
    outputView.string = @"";
    _task = [[AMShellTask alloc] initWithCommand:command];
    [_task launch];
    NSFileHandle *inputStream = [_task fileHandlerForReading];
//    NSMutableString *content = [[NSMutableString alloc] init];
//    AMPingViewController * __weak weakSelf = self;
    
    inputStream.readabilityHandler = ^ (NSFileHandle *fh) {
        NSData *data = [fh availableData];
        NSString *string = [[NSString alloc] initWithData:data
                                                 encoding:NSUTF8StringEncoding];
        NSDictionary *attr = @{
            NSForegroundColorAttributeName : UI_Color_b7b7b7
        };
        NSAttributedString *attrString =
            [[NSAttributedString alloc] initWithString:string attributes:attr];
        [outputView.textStorage appendAttributedString:attrString];
        outputView.needsDisplay = YES;
        
//        [content appendString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
//        AMPingViewController *strongSelf = weakSelf;
//        strongSelf.outputTextView.string = content;
        
    };
}

@end
