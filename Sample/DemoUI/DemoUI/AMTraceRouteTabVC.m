//
//  AMTraceRouteTabVC.m
//  Artsmesh
//
//  Created by whiskyzed on 6/29/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMTraceRouteTabVC.h"
#import "UIFramework/AMFoundryFontView.h"
#import "UIFramework/AMCheckBoxView.h"
#import "UIFramework/AMRatioButtonView.h"
#import "UIFramework/AMUIConst.h"

@interface AMTraceRouteTabVC ()<AMUserListDelegate>
{
    AMUserList* userList;
}

@property (weak) IBOutlet NSTableView *tableView;
@property (unsafe_unretained) IBOutlet NSTextView *traceContentView;

@end

@implementation AMTraceRouteTabVC


- (void) awakeFromNib
{
    [super awakeFromNib];
    
    userList = [[AMUserList alloc] init:self.tableView];
    userList.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    userList.pingCommand.contentView = self.traceContentView;
    [userList userGroupsChangedPing:nil];
}

-(NSString*) formatCommand:(NSString*) ip
{
    NSString* command;
    
    if ([AMCommonTools isValidIpv4:ip] || [AMCommonTools isValidIpv6:ip]){
        command = [NSString stringWithFormat:@"traceroute %@", ip];
    }
    
    return command;
}



@end
