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
#import "UIFramework/AMBlueBorderButton.h"

#import "AMPreferenceManager/AMPreferenceManager.h"



@interface AMJacktripSettingsVC ()<AMCheckBoxDelegeate, NSTextFieldDelegate, AMPopUpViewDelegeate>

@property (weak) IBOutlet AMPopUpView *roleCombo;
@property (weak) IBOutlet AMFoundryFontView *channelCountField;
@property (weak) IBOutlet AMFoundryFontView *recvCountField;
@property (weak) IBOutlet AMFoundryFontView *qblField;
@property (weak) IBOutlet AMFoundryFontView *prField;
@property (weak) IBOutlet AMFoundryFontView *brsField;
@property (weak) IBOutlet AMCheckBoxView *zeroUnderRunCheck;
@property (weak) IBOutlet AMCheckBoxView *loopBackCheck;
@property (weak) IBOutlet AMCheckBoxView *jumLink;
@property (weak) IBOutlet AMCheckBoxView *useIPv6Check;
@property (weak) IBOutlet AMBlueBorderButton *saveBtn;
@property (weak) IBOutlet AMBlueBorderButton *cancelBtn;
@property (weak) IBOutlet AMPopUpView *hubPatchCombo;
@property (weak) IBOutlet AMPopUpView *bufStrategyCombo;
@property (weak) IBOutlet AMCheckBoxView *includeServerCheck;
@property (weak) IBOutlet AMCheckBoxView *monoToStereoCheck;

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
    [self.roleCombo addItemWithTitle:@"P2P CLIENT"];
    [self.roleCombo addItemWithTitle:@"P2P SERVER"];
    [self.roleCombo addItemWithTitle:@"HUB CLIENT"];
    [self.roleCombo addItemWithTitle:@"HUB SERVER"];
    
    self.zeroUnderRunCheck.title = @"ZeroUnderRun[-z]";
    self.jumLink.title = @"jamlink[-j]";
    self.loopBackCheck.title = @"Loopback[-l]";
    self.useIPv6Check.title = @"Use Ipv6[-V]";
    
    [self.hubPatchCombo addItemWithTitle:@"0"];
    [self.hubPatchCombo addItemWithTitle:@"1"];
    [self.hubPatchCombo addItemWithTitle:@"2"];
    [self.hubPatchCombo addItemWithTitle:@"3"];
    [self.hubPatchCombo addItemWithTitle:@"4"];
    [self.hubPatchCombo addItemWithTitle:@"5"];
    
    [self.bufStrategyCombo  addItemWithTitle:@"0"];
    [self.bufStrategyCombo  addItemWithTitle:@"1"];
    [self.bufStrategyCombo  addItemWithTitle:@"2"];
    [self.bufStrategyCombo  addItemWithTitle:@"3"];
    [self.bufStrategyCombo  addItemWithTitle:@"4"];
    
    self.includeServerCheck.title   = @"IncludeServerInPatching";
    self.monoToStereoCheck.title    = @"UpmixClientMonoToStereo";
    
    self.zeroUnderRunCheck.delegate = self;
    self.jumLink.delegate = self;
    self.loopBackCheck.delegate = self;
    self.zeroUnderRunCheck.delegate = self;
    
    self.channelCountField.delegate = self;
    self.recvCountField.delegate    = self;
    
    self.qblField.delegate = self;
    self.prField.delegate = self;
    self.brsField.delegate = self;
    
    self.roleCombo.delegate         = self;
    self.hubPatchCombo.delegate     = self;
    self.bufStrategyCombo.delegate  = self;
    self.includeServerCheck.delegate    = self;
    self.monoToStereoCheck.delegate     = self;
    
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
    
    NSString *recvCountStr = [[AMPreferenceManager standardUserDefaults]
                              stringForKey:Preference_Jacktrip_RecvCount];
    self.recvCountField.stringValue = recvCountStr;
    
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
    
    NSString* hubPatchStr = [[AMPreferenceManager standardUserDefaults]
                             stringForKey:Preference_Jacktrip_HubPatch];
    if (hubPatchStr != nil) {
        [self.hubPatchCombo selectItemWithTitle:hubPatchStr];
    }
    
    NSString* bufStrategyStr = [[AMPreferenceManager standardUserDefaults]
                             stringForKey:Preference_Jacktrip_BufStrategy];
    if (bufStrategyStr != nil) {
        [self.bufStrategyCombo selectItemWithTitle:bufStrategyStr];
    }
    
    NSString *incServerStr  = [[AMPreferenceManager standardUserDefaults]
                             stringForKey:Preference_Jacktrip_IncludeServer];
    if ([incServerStr isEqualToString:@"YES"]) {
        self.includeServerCheck.checked = YES;
    }else{
        self.includeServerCheck.checked = NO;
    }
    
    NSString *monoStereoStr  = [[AMPreferenceManager standardUserDefaults]
                             stringForKey:Preference_Jacktrip_MonoToStereo];
    if ([monoStereoStr isEqualToString:@"YES"]) {
        self.monoToStereoCheck.checked = YES;
    }else{
        self.monoToStereoCheck.checked = NO;
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
    [[AMPreferenceManager standardUserDefaults] setObject:self.recvCountField.stringValue forKey:Preference_Jacktrip_RecvCount];
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
    
    [[AMPreferenceManager standardUserDefaults] setObject:self.hubPatchCombo.stringValue forKey:Preference_Jacktrip_HubPatch];
    
    [[AMPreferenceManager standardUserDefaults] setObject:self.bufStrategyCombo.stringValue forKey:Preference_Jacktrip_BufStrategy];
    
    if (self.includeServerCheck.checked) {
        [[AMPreferenceManager standardUserDefaults] setObject:@"YES" forKey:Preference_Jacktrip_IncludeServer];
    }else{
        [[AMPreferenceManager standardUserDefaults] setObject:@"NO" forKey:Preference_Jacktrip_IncludeServer];
    }
    
    if (self.monoToStereoCheck.checked) {
        [[AMPreferenceManager standardUserDefaults] setObject:@"YES" forKey:Preference_Jacktrip_MonoToStereo];
    }else{
        [[AMPreferenceManager standardUserDefaults] setObject:@"NO" forKey:Preference_Jacktrip_MonoToStereo];
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
