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
    
    timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(reloadTable) userInfo:nil repeats:NO];
    
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
    }
}

@end
