//
//  AMPingTabVC.m
//  Artsmesh
//
//  Created by whiskyzed on 6/8/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMPingTabVC.h"

#import "AMCoreData/AMCoreData.h"
#import "AMNetworkToolsCommand.h"
#import "AMCommonTools/AMCommonTools.h"

#import "UIFramework/AMFoundryFontView.h"
#import "UIFramework/AMCheckBoxView.h"
#import "UIFramework/AMRatioButtonView.h"

@interface AMPingTabVC () <NSTableViewDataSource, NSTableViewDelegate>

{
    AMNetworkToolsCommand *     _pingCommand;
    NSArray *_users;
}

@property (weak)                IBOutlet NSTableView*   tableView;
@property (unsafe_unretained)   IBOutlet NSTextView *   pingContentView;
@end

@implementation AMPingTabVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    _pingCommand = [[AMNetworkToolsCommand alloc] init];
    _pingCommand.contentView = self.pingContentView;
    
    
     [[NSNotificationCenter defaultCenter]
                                addObserver:self
                                selector:@selector(userGroupsChangedPing:)
                                name: AM_LIVE_GROUP_CHANDED
                                object:nil];
    
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    if (mySelf.isOnline)
    {
        [self userGroupsChangedPing:nil];
    }
}

-(void)userGroupsChangedPing:(NSNotification*)notification
{
    AMLiveGroup* mergedGroup = [[AMCoreData shareInstance] mergedGroup];
    _users = [mergedGroup usersIncludeSubGroup];
    
    [self.tableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return _users.count;
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
    
    NSString *command;
        
    if ([AMCommonTools isValidIpv4:ip]){
        command = [NSString stringWithFormat:@"ping -c 5 %@", ip];
    }else{
        command = [NSString stringWithFormat:@"ping6 -c 5 %@", ip];
    }
        
    [_pingCommand stop];
    _pingCommand.command = command;
    [_pingCommand run];
}




@end
