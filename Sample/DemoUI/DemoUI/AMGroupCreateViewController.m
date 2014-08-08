//
//  AMGroupCreateViewController.m
//  DemoUI
//
//  Created by Wei Wang on 8/5/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMGroupCreateViewController.h"
#import "UIFramework/AMButtonHandler.h"
#import "AMStatusNet/AMStatusNet.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "UIFramework/AMFoundryFontView.h"

@interface AMGroupCreateViewController ()
@property (weak) IBOutlet NSButton *createBtn;
@property (weak) IBOutlet AMFoundryFontView *nickNameField;

@end

@implementation AMGroupCreateViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)awakeFromNib
{
    [AMButtonHandler changeTabTextColor:self.createBtn toColor:UI_Color_blue];
}


- (IBAction)createGroup:(NSButton *)sender
{
    NSUserDefaults* defaults = [AMPreferenceManager standardUserDefaults];
    NSString* account = [defaults stringForKey:Preference_Key_StatusNet_UserName];
    NSString* password = [defaults stringForKey:Preference_Key_StatusNet_Password];
    
    if (account == nil) {
        return;
    }
    
    if ([account isEqualToString:@""]) {
        return ;
    }
    
    NSString* nickName = self.nickNameField.stringValue;
    [[AMStatusNet shareInstance] createGroup:nickName account: account password:password];
}

@end
