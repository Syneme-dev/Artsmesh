//
//  AMStatusNetSettingsVC.m
//  Artsmesh
//
//  Created by 王为 on 11/2/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMAccountSettingsVC.h"
#import "AMStatusNet/AMStatusNet.h"
#import "UIFramework/AMButtonHandler.h"

@interface AMAccountSettingsVC ()
@property (weak) IBOutlet NSButton *postBtn;
@property (weak) IBOutlet NSTextField *postResField;

@end

@implementation AMAccountSettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [AMButtonHandler changeTabTextColor:self.postBtn toColor:UI_Color_blue];
}


- (IBAction)statusNetTest:(id)sender {
    BOOL res = [[AMStatusNet shareInstance]
                postMessageToStatusNet:@"This is a test message send from Artsmesh through API"];
    if (res)
    {
        self.postResField.stringValue = @"Post Succeeded!";
    }
    else
    {
        self.postResField.stringValue = @"Post Failed!";
    }
}

@end
