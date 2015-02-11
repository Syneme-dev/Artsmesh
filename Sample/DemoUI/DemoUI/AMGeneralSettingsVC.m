//
//  AMGeneralSettingsVC.m
//  Artsmesh
//
//  Created by 王为 on 11/2/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMGeneralSettingsVC.h"
#import "UIFramework/AMPopUpView.h"
#import "UIFramework/AMCheckBoxView.h"

@interface AMGeneralSettingsVC ()

@property (weak) IBOutlet NSTextField *machineNameField;
@property (weak) IBOutlet AMPopUpView *privateIpBox;
@property (weak) IBOutlet NSTextField *localServerPortField;
@property (weak) IBOutlet AMCheckBoxView *ipv6Check;
@property (weak) IBOutlet AMCheckBoxView *assignedLocalServerCheck;
@property (weak) IBOutlet NSTextField *assignedLocalServerField;
@property (weak) IBOutlet NSTextField *globalServerAddrField;
@property (weak) IBOutlet NSTextField *globalServerPortField;
@property (weak) IBOutlet NSTextField *chatPortField;
@property (weak) IBOutlet AMCheckBoxView *useOSCForChatCheck;
@property (weak) IBOutlet AMCheckBoxView *topBarCheck;


@end

@implementation AMGeneralSettingsVC
{
    dispatch_queue_t _loading_queue;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
}

@end
