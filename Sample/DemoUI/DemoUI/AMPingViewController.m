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

@interface AMPingViewController ()
{
    NSTask *_task;
    NSFileHandle *_pipeIn;
}

- (void)runTask:(NSString *)command;
- (void)cancelTask;

@end

@implementation AMPingViewController
{
    NSTimer* timer;
    NSArray* _myGroupUsers;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    timer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(reloadTable) userInfo:nil repeats:NO];
    
    return self;
}

-(void)reloadTable
{
    AMMesher* mesher = [AMMesher sharedAMMesher];
    _myGroupUsers = mesher.myGroupUsers;
    [self.userTable reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    AMMesher* mesher = [AMMesher sharedAMMesher];
    return [mesher.myGroupUsers count];
}

- (id)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {

    NSTableCellView *result = [tableView makeViewWithIdentifier:[tableColumn identifier] owner:nil];
    
    AMUser* user = [_myGroupUsers objectAtIndex:row];
    [result.textField setStringValue:user.nodeName];
    return result;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    if(_myGroupUsers)
    {
        AMUser* user = [_myGroupUsers objectAtIndex:self.userTable.selectedRow];
        NSString* ip = user.publicIp;
        NSString *pingCommand = [NSString stringWithFormat:@"ping -c 5 %@", ip];
        [self runTask:pingCommand];
    }
}

- (void)cancelTask
{
    if (_task) {
        @try {
            _pipeIn.readabilityHandler = nil;
            [_task interrupt];
        }
        @catch (NSException *exception) {
            // ignore
        }
        @finally {
            _task = nil;
            _pipeIn = nil;
        }
    }
}

- (void)runTask:(NSString *)command
{
    [self cancelTask];
    self.outputTextView.string = @"";
    
    _task = [[NSTask alloc] init];
    _task.launchPath = @"/bin/bash";
    _task.arguments = @[@"-c", command];
    
    NSPipe *pipe = [NSPipe pipe];
    _task.standardOutput = pipe;
    _task.standardError = pipe;
    [_task launch];
    
    _pipeIn = [pipe fileHandleForReading];
    NSMutableString *content = [[NSMutableString alloc] init];
    AMPingViewController * __weak weakSelf = self;
    _pipeIn.readabilityHandler = ^ (NSFileHandle *fh) {
        NSData *data = [fh availableData];
        [content appendString:[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]];
        AMPingViewController *strongSelf = weakSelf;
        strongSelf.outputTextView.string = content;
    };
}

@end
