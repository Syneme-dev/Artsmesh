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
#import "AMUserList.h"

@interface AMTraceRouteTabVC ()<AMUserListDelegate>
{
    AMUserList* userList;
}

@property (weak) IBOutlet NSTableView *tableView;
@property (unsafe_unretained) IBOutlet NSTextView *traceContentView;
@property (weak) IBOutlet AMCheckBoxView *useIPV6Check;
@property (weak) IBOutlet NSView *inputField;

@end

@implementation AMTraceRouteTabVC


- (void) awakeFromNib
{
    [super awakeFromNib];
    
    userList = [[AMUserList alloc] init:self.tableView
                             inputField:_inputField];
    userList.delegate = self;
    self.useIPV6Check.title = @"USE IPV6";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    userList.pingCommand.contentView = self.traceContentView;
    [userList userGroupsChangedPing:nil];
}

- (BOOL) useIPV6
{
    return self.useIPV6Check.checked;
}

-(NSString*) formatCommand:(NSString*) ip
{
    NSString* command;
   
    if ([self useIPV6] && [AMCommonTools isValidIpv6:ip]) {
        command = [NSString stringWithFormat:@"traceroute6 %@", ip];
    }else{
        command = [NSString stringWithFormat:@"traceroute %@", ip];
    }

    return command;
}



@end
