//
//  AMIPerfTabVC.m
//  Artsmesh
//
//  Created by whiskyzed on 6/8/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMIPerfTabVC.h"
#import "UIFramework/AMFoundryFontView.h"
#import "UIFramework/AMCheckBoxView.h"
#import "UIFramework/AMRatioButtonView.h"
#import "AMPingTabVC.h"


@interface AMIPerfTabVC ()<AMUserListDelegate>
{
    AMUserList* userList;
}
@property (weak) IBOutlet NSButton *settingButton;
@property (weak) IBOutlet AMCheckBoxView *useIPV4;
@property (weak) IBOutlet NSTableView *tableView;
@property (unsafe_unretained) IBOutlet NSTextView *iperfContentView;

@end

@implementation AMIPerfTabVC

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    userList = [[AMUserList alloc] init:self.tableView];
    userList.delegate = self;
    userList.pingCommand.contentView = self.iperfContentView;
    
    [userList userGroupsChangedPing:nil];
    
    //self.useIPV4.delegate = self;
    self.useIPV4.title = @"USE IPV4";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    
}

-(NSString*) formatCommand:(NSString*) ip
{
    NSString* command;
    
    if ([AMCommonTools isValidIpv4:ip]){
        command = [NSString stringWithFormat:@" iperf -c  %@ -u -V -b10M", ip];
    }
    
    return command;
}


@end
