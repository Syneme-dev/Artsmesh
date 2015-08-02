//
//  AMPingTabVC.m
//  Artsmesh
//
//  Created by whiskyzed on 6/8/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMPingTabVC.h"



#import "UIFramework/AMFoundryFontView.h"
#import "UIFramework/AMCheckBoxView.h"
#import "UIFramework/AMRatioButtonView.h"

#import "AMCommonTools/AMCommonTools.h"
#import "AMUserList.h"


@interface AMPingTabVC () <AMUserListDelegate>
{
    AMUserList* userList;
}
@property (weak) IBOutlet AMCheckBoxView *useIPV6Check;
@property (weak) IBOutlet NSView *inputField;

@property (weak)                IBOutlet NSTableView*   tableView;
@property (unsafe_unretained)   IBOutlet NSTextView *   pingContentView;
@end

@implementation AMPingTabVC

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
         //
        
    }
    return self;
}

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
    userList.pingCommand.contentView = self.pingContentView;
    [userList userGroupsChangedPing:nil];
}

- (BOOL) useIPV6
{
    return self.useIPV6Check.checked;
}


-(NSString*) formatCommand:(NSString*) ip
{
    NSString* command;
    
    if ([self useIPV6]){
        command = [NSString stringWithFormat:@"ping6 -c 5 %@", ip];
    }else{
        command = [NSString stringWithFormat:@"ping -c 5 %@", ip];
    }

    return command;
}


- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    
}




@end
