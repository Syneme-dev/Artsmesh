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

static void *PingKVOContext;

@interface AMPingViewController ()
{
    NSTask *_task;
    NSFileHandle *_pipeIn;
    AMMesher *_mesher;
    NSArray *_myGroupUsers;
}

- (void)runTask:(NSString *)command;
- (void)cancelTask;

@end

@implementation AMPingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _mesher = [AMMesher sharedAMMesher];
        _myGroupUsers = _mesher.myGroupUsers;
    }
    
    return self;
}

- (void)awakeFromNib
{
    [_mesher addObserver:self
              forKeyPath:@"usergroupDest.userGroups"
                 options:0
                 context:&PingKVOContext];
    
    NSColor *color = [NSColor whiteColor];
    [self.outputTextView setTextColor:color];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context != &PingKVOContext) {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
        return;
    }
    
    _myGroupUsers = _mesher.myGroupUsers;
    [self.userTable reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_myGroupUsers count];
}

- (id)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {

    NSTableCellView *result = [tableView makeViewWithIdentifier:[tableColumn identifier] owner:nil];
    
    AMUser* user = _myGroupUsers[row];
    [result.textField setStringValue:user.nodeName];
    return result;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    AMUser* user = _myGroupUsers[self.userTable.selectedRow];
    NSString *pingCommand = [NSString stringWithFormat:@"ping -c 5 %@",
                                user.publicIp];
    [self runTask:pingCommand];
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
