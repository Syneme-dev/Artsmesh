//
//  AMJacktripSettings.m
//  DemoUI
//
//  Created by wangwei on 5/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMJacktripSettingsVC.h"
#import "UIFramework/AMCheckBoxView.h"
#import "UIFramework/AMFoundryFontView.h"
#import "UIFramework/AMPopUpView.h"
#import "UIFramework/AMButtonHandler.h"
#import "AMPreferenceManager/AMPreferenceManager.h"


@interface AMJacktripSettingsVC ()<AMCheckBoxDelegeate, NSTextFieldDelegate, AMPopUpViewDelegeate>

@property (weak) IBOutlet AMPopUpView *roleCombo;
@property (weak) IBOutlet AMFoundryFontView *channelCountField;
@property (weak) IBOutlet AMFoundryFontView *qblField;
@property (weak) IBOutlet AMFoundryFontView *prField;
@property (weak) IBOutlet AMFoundryFontView *brsField;
@property (weak) IBOutlet AMCheckBoxView *zeroUnderRunCheck;
@property (weak) IBOutlet AMCheckBoxView *loopBackCheck;
@property (weak) IBOutlet AMCheckBoxView *jumLink;
@property (weak) IBOutlet AMCheckBoxView *useIPv6Check;
@property (weak) IBOutlet NSButton *saveBtn;
@property (weak) IBOutlet NSButton *cancelBtn;


@end

@implementation AMJacktripSettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self setUpUI];
    [self loadUserPref];
}


-(void)setUpUI
{
    [self.roleCombo addItemWithTitle:@"Client"];
    [self.roleCombo addItemWithTitle:@"Server"];
    
    self.zeroUnderRunCheck.title = @"ZeroUnderRun[-z]";
    self.jumLink.title = @"jamlink[-j]";
    self.loopBackCheck.title = @"Loopback[-l]";
    self.useIPv6Check.title = @"Use Ipv6[-V]";
    
    self.zeroUnderRunCheck.delegate = self;
    self.jumLink.delegate = self;
    self.loopBackCheck.delegate = self;
    self.zeroUnderRunCheck.delegate = self;
    
    self.channelCountField.delegate = self;
    self.qblField.delegate = self;
    self.prField.delegate = self;
    self.brsField.delegate = self;
    
    self.roleCombo.delegate = self;
    
    [AMButtonHandler changeTabTextColor:self.saveBtn toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.cancelBtn toColor:UI_Color_blue];
}


-(BOOL)control:(NSControl *)control textShouldBeginEditing:(NSText *)fieldEditor
{
    [self.saveBtn setEnabled:YES];
    [self.cancelBtn setEnabled:YES];
    
    return YES;
}


-(void)onChecked:(AMCheckBoxView*)sender
{
    [self.saveBtn setEnabled:YES];
    [self.cancelBtn setEnabled:YES];
}

-(void)itemSelected:(AMPopUpView*)sender
{
    [self.saveBtn setEnabled:YES];
    [self.cancelBtn setEnabled:YES];
}

-(void)loadUserPref
{
    NSString* roleStr = [[AMPreferenceManager standardUserDefaults]
                         stringForKey:Preference_Jacktrip_Role];
    if (roleStr != nil) {
        [self.roleCombo selectItemWithTitle:roleStr];
    }
    
    NSString *channelCountStr = [[AMPreferenceManager standardUserDefaults]
                              stringForKey:Preference_Jacktrip_ChannelCount];
    self.channelCountField.stringValue = channelCountStr;
    
    NSString *queueBufLenStr = [[AMPreferenceManager standardUserDefaults]
                                 stringForKey:Preference_Jacktrip_QBL];
    self.qblField.stringValue = queueBufLenStr;
    
    NSString *packetRedStr = [[AMPreferenceManager standardUserDefaults]
                                stringForKey:Preference_Jacktrip_PR];
    self.prField.stringValue =packetRedStr;
    
    NSString *bitRateResStr = [[AMPreferenceManager standardUserDefaults]
                              stringForKey:Preference_Jacktrip_BRR];
    self.brsField.stringValue = bitRateResStr;
    
    NSString *zeroUnderRun = [[AMPreferenceManager standardUserDefaults]
                              stringForKey:Preference_Jacktrip_ZeroUnderRun];
    if ([zeroUnderRun isEqualToString:@"YES"]) {
        self.zeroUnderRunCheck.checked = YES;
    }else{
        self.zeroUnderRunCheck.checked = NO;
    }
    
    NSString *loopBackStr = [[AMPreferenceManager standardUserDefaults]
                              stringForKey:Preference_Jacktrip_Loopback];
    if ([loopBackStr isEqualToString:@"YES"]) {
        self.loopBackCheck.checked = YES;
    }else{
        self.loopBackCheck.checked = NO;
    }
    
    NSString *jamlinkStr = [[AMPreferenceManager standardUserDefaults]
                             stringForKey:Preference_Jacktrip_Jamlink];
    if ([jamlinkStr isEqualToString:@"YES"]) {
        self.jumLink.checked = YES;
    }else{
        self.jumLink.checked = NO;
    }
    
    NSString *userIpv6Str = [[AMPreferenceManager standardUserDefaults]
                            stringForKey:Preference_Jacktrip_UseIpv6];
    if ([userIpv6Str isEqualToString:@"YES"]) {
        self.useIPv6Check.checked = YES;
    }else{
        self.useIPv6Check.checked = NO;
    }
    
    [self.saveBtn setEnabled:NO];
    [self.cancelBtn setEnabled:NO];
}


-(BOOL)checkUserInput
{
    if ([self.channelCountField.stringValue isEqualToString:@""]) {
        return NO;
    }
    
    if ([self.prField.stringValue isEqualToString:@""]) {
        return NO;
    }
    
    if ([self.qblField.stringValue isEqualToString:@""]) {
        return NO;
    }
    
    if ([self.brsField.stringValue isEqualToString:@""]) {
        return NO;
    }
    
    return YES;
}


-(void)saveUserPref
{
    [[AMPreferenceManager standardUserDefaults] setObject:self.roleCombo.stringValue forKey:Preference_Jacktrip_Role];
    [[AMPreferenceManager standardUserDefaults] setObject:self.channelCountField.stringValue forKey:Preference_Jacktrip_ChannelCount];
    [[AMPreferenceManager standardUserDefaults] setObject:self.brsField.stringValue forKey:Preference_Jacktrip_BRR];
    [[AMPreferenceManager standardUserDefaults] setObject:self.prField.stringValue forKey:Preference_Jacktrip_PR];
    [[AMPreferenceManager standardUserDefaults] setObject:self.qblField.stringValue forKey:Preference_Jacktrip_QBL];
    
    if (self.loopBackCheck.checked) {
         [[AMPreferenceManager standardUserDefaults] setObject:@"YES" forKey:Preference_Jacktrip_Loopback];
    }else{
        [[AMPreferenceManager standardUserDefaults] setObject:@"NO" forKey:Preference_Jacktrip_Loopback];
    }
    
    if (self.useIPv6Check.checked) {
        [[AMPreferenceManager standardUserDefaults] setObject:@"YES" forKey:Preference_Jacktrip_UseIpv6];
    }else{
        [[AMPreferenceManager standardUserDefaults] setObject:@"NO" forKey:Preference_Jacktrip_UseIpv6];
    }
    
    if (self.jumLink.checked) {
        [[AMPreferenceManager standardUserDefaults] setObject:@"YES" forKey:Preference_Jacktrip_Jamlink];
    }else{
        [[AMPreferenceManager standardUserDefaults] setObject:@"NO" forKey:Preference_Jacktrip_Jamlink];
    }
    
    if (self.zeroUnderRunCheck.checked) {
        [[AMPreferenceManager standardUserDefaults] setObject:@"YES" forKey:Preference_Jacktrip_ZeroUnderRun];
    }else{
        [[AMPreferenceManager standardUserDefaults] setObject:@"NO" forKey:Preference_Jacktrip_ZeroUnderRun];
    }
    
    [self.saveBtn setEnabled:NO];
    [self.cancelBtn setEnabled:NO];
}

- (IBAction)savePref:(id)sender
{
    if ([self checkUserInput]) {
        [self saveUserPref];
    }else{
        NSAlert *alert = [NSAlert alertWithMessageText:@"ErrorInput" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please check your parameters!"];
        [alert runModal];
    }
}

- (IBAction)cancelPref:(id)sender
{
    [self loadUserPref];
}

@end
