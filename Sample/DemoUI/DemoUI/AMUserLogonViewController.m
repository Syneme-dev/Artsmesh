//
//  AMUserLogonViewController.m
//  DemoUI
//
//  Created by Wei Wang on 7/24/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMUserLogonViewController.h"
#import "UIFramework/AMButtonHandler.h"
#import "AMStatusNet/AMStatusNet.h"
#import "AMPreferenceManager/AMPreferenceManager.h"


@interface AMUserLogonViewController ()
@property (weak) IBOutlet NSButton *loginBtn;
@property (weak) IBOutlet NSButton *registerBtn;
@property (weak) IBOutlet NSSecureTextField *passwordField;
@property (weak) IBOutlet NSSecureTextField *passwordConfirmField;

@property (weak) IBOutlet NSTextField *nickNameErr;
@property (weak) IBOutlet NSTextField *passwordErr;
@property (weak) IBOutlet NSTextField *passwordConfirmErr;

@end

@implementation AMUserLogonViewController

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
    [AMButtonHandler changeTabTextColor:self.loginBtn toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.registerBtn toColor:UI_Color_blue];
}

- (IBAction)registerStatusNet:(NSButton *)sender
{
    self.nickNameErr.stringValue = @"";
    self.passwordErr.stringValue = @"";
    self.passwordConfirmErr.stringValue = @"";
    
    NSUserDefaults* defaults = [AMPreferenceManager standardUserDefaults];
    NSString* url = [defaults stringForKey:Preference_Key_StatusNet_URL];
    if(url == nil || [url isEqualToString:@""]){
        return;
    }
    
    NSString* password = self.passwordField.stringValue;
    if (password == nil || [password isEqualToString:@""]) {
        self.passwordErr.stringValue = @"!";
        return;
    }
    
    NSString* passwordConfirm = self.passwordConfirmField.stringValue;
    if (![passwordConfirm isEqualToString:password]) {
        self.passwordConfirmErr.stringValue = @"!";
        return;
    }
    
    BOOL res = [[AMStatusNet shareInstance] registerAccount:self.nickName password:password];
    if (!res) {
        self.passwordErr.stringValue = @"!";
        return;
    }
    
    [defaults setObject: self.nickName forKey:Preference_Key_StatusNet_UserName];
    [defaults setObject:password forKey:Preference_Key_StatusNet_Password];
    
}


- (IBAction)loginStatusNet:(NSButton *)sender
{
    self.nickNameErr.stringValue = @"";
    self.passwordErr.stringValue = @"";
    self.passwordConfirmErr.stringValue = @"";
    
    NSUserDefaults* defaults = [AMPreferenceManager standardUserDefaults];
    NSString* url = [defaults stringForKey:Preference_Key_StatusNet_URL];
    if(url == nil || [url isEqualToString:@""]){
        return;
    }
    
    NSString* password = self.passwordField.stringValue;
    BOOL res = [[AMStatusNet shareInstance] loginAccount:self.nickName password:password];
    if (!res) {
        self.passwordErr.stringValue = @"!";
        return;
    }

    [defaults setObject: self.nickName forKey:Preference_Key_StatusNet_UserName];
    [defaults setObject:password forKey:Preference_Key_StatusNet_Password];
}

@end
