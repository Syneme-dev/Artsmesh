//
//  AMUserViewController.m
//  DemoUI
//
//  Created by 王 为 on 3/31/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMUserViewController.h"

#import <AMNotificationManager/AMNotificationManager.h>
#import "AMRestHelper.h"
#import "AFHTTPRequestOperationManager.h"
#import <UIFramework/AMButtonHandler.h>
#import "AMMesher/AMMesher.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "AMCoreData/AMCoreData.h"
#import "AMMesher/AMMesher.h"
#import "AMUserLogonViewController.h"
#import "UIFrameWork/AMCheckBoxView.h"
#import "AMStatusNet/AMStatusNet.h"
#import "UIFrameWork/AMFoundryFontView.h"
#import "AMGroupCreateViewController.h"

@interface AMUserViewController ()<AMCheckBoxDelegeate, NSPopoverDelegate>
@property (weak) IBOutlet AMCheckBoxView *groupBusyCheckbox;
@property (weak) IBOutlet AMCheckBoxView *userBusyCheckBox;
@property (weak) IBOutlet NSImageView *userStatusIcon;
@property (weak) IBOutlet NSImageView *groupStatusIcon;
@property (weak) IBOutlet AMFoundryFontView *groupNameField;
@property (weak) IBOutlet AMFoundryFontView *nickNameField;
@property (weak) IBOutlet AMFoundryFontView *fullNameField;
@property (weak) IBOutlet AMFoundryFontView *locationField;
@property (weak) IBOutlet AMFoundryFontView *affiliationField;
@property (weak) IBOutlet AMFoundryFontView *biographyField;

@property NSPopover *myPopover;

@end

@implementation AMUserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}


-(void)awakeFromNib
{
    [super awakeFromNib];
    [self.statusMessageLabel setFont: [NSFont fontWithName: @"FoundryMonoline" size: self.statusMessageLabel.font.pointSize]];
    [AMButtonHandler changeTabTextColor:self.userTabButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.groupTabButton toColor:UI_Color_blue];
    self.groupBusyCheckbox.title = @"BUSY";
    self.groupBusyCheckbox.delegate = self;
    self.userBusyCheckBox.title = @"BUSY";
    self.userBusyCheckBox.delegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localGroupChanging) name:AM_MYGROUP_CHANGING_LOCAL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(localGroupChanged) name:AM_MYGROUP_CHANGED_LOCAL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mySelfChanging) name:AM_MYSELF_CHANGING_LOCAL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(myselfChanged) name:AM_MYSELF_CHANGED_LOCAL object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteGroupChanging) name:AM_MYGROUP_CHANGING_REMOTE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteGroupChanged) name:AM_MYGROUP_CHANGED_REMOTE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteMyselfChanging) name:AM_MYSELF_CHANGING_REMOTE object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(remoteMyselfChanged) name:AM_MYSELF_CHANGED_REMOTE object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userListChenged) name:AM_LIVE_GROUP_CHANDED object:nil];
    
    self.userBusyCheckBox.checked = [AMCoreData shareInstance].mySelf.busy;
    self.groupBusyCheckbox.checked = [AMCoreData shareInstance].myLocalLiveGroup.busy;
    [self loadUserAvatar];
    [self loadGroupAvatar];
    
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)userListChenged
{
    [self localGroupChanged];
    [self myselfChanged];
    [self remoteGroupChanged];
    [self remoteMyselfChanged];
}

-(void)remoteGroupChanging
{
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    if(mySelf.isOnline == NO) {
        return;
    }

    [self.groupStatusIcon setImage:[NSImage imageNamed:@"synchronizing_icon"]];
}

-(void)remoteGroupChanged
{
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    if(mySelf.isOnline == NO) {
        return;
    }
    
    AMLiveGroup* myGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    if (myGroup.busy) {
        [self.groupStatusIcon setImage:[NSImage imageNamed:@"groupuser_busy"]];
    }else{
        [self.groupStatusIcon setImage:[NSImage imageNamed:@"groupuser_meshed_icon"]];
    }
}

-(void)remoteMyselfChanging
{
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    if(mySelf.isOnline == NO) {
        return;
    }

    [self.userStatusIcon setImage:[NSImage imageNamed:@"synchronizing_icon"]];
}

-(void)remoteMyselfChanged
{
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    if(mySelf.isOnline == NO) {
        return;
    }
    
    if (mySelf.busy) {
        [self.userStatusIcon setImage:[NSImage imageNamed:@"groupuser_busy"]];
    }else{
        [self.userStatusIcon setImage:[NSImage imageNamed:@"groupuser_meshed_icon"]];
    }
}

-(void)localGroupChanging
{
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    if(mySelf.isOnline == YES) {
        return;
    }
    
    [self.groupStatusIcon setImage:[NSImage imageNamed:@"synchronizing_icon"]];
}

-(void)localGroupChanged
{
    AMLiveGroup* localGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    [[AMPreferenceManager standardUserDefaults]
     setObject:localGroup.groupName forKey:Preference_Key_Cluster_Name];
    
    [[AMPreferenceManager standardUserDefaults]
     setObject:localGroup.fullName forKey:Preference_Key_Cluster_FullName];
    
    [[AMPreferenceManager standardUserDefaults]
     setObject:localGroup.project forKey:Preference_Key_Cluster_Project];
    
    [[AMPreferenceManager standardUserDefaults]
     setObject:localGroup.location forKey:Preference_Key_Cluster_Location];
    
    [[AMPreferenceManager standardUserDefaults]
     setObject:localGroup.description forKey:Preference_Key_Cluster_Description];
    
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    if(mySelf.isOnline == YES) {
        return;
    }

    [self loadGroupAvatar];
    [self.groupStatusIcon setImage:[NSImage imageNamed:@"group_unmeshed_icon"]];
}

-(void)mySelfChanging
{
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    if(mySelf.isOnline == YES) {
        return;
    }
    
    [self.userStatusIcon setImage:[NSImage imageNamed:@"synchronizing_icon"]];
}

-(void)myselfChanged
{
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    if(mySelf.isOnline == YES) {
        return;
    }
    
    [self loadUserAvatar];
    [self.userStatusIcon setImage:[NSImage imageNamed:@"user_unmeshed_icon"]];
}

-(void)registerTabButtons{
    super.tabs=self.tabs;
    self.tabButtons =[[NSMutableArray alloc]init];
    [self.tabButtons addObject:self.userTabButton];
    [self.tabButtons addObject:self.groupTabButton];
    self.showingTabsCount=2;
    
}

-(void)loadUserAvatar
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString * myUserName = [defaults stringForKey:Preference_Key_StatusNet_UserName];
    
    [[AMStatusNet shareInstance] loadUserAvatar:myUserName requestCallback:^(NSImage* image, NSError* err){
        if (err != nil) {
            return;
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.userAvatarView setImage:image];
            });
        }
    }];
}

-(void)loadGroupAvatar
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString * myGroupName = [defaults stringForKey:Preference_Key_Cluster_Name];
    
    [[AMStatusNet shareInstance] loadGroupAvatar:myGroupName requestCallback:^(NSImage* image, NSError* err){
        if (err != nil) {
            return;
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.groupAvatarView setImage:image];
            });
        }
    }];

}


- (IBAction)onUserTabClick:(id)sender
{
    [self.tabs selectTabViewItemAtIndex:0];
}

- (IBAction)onGroupTabClick:(id)sender
{
    [self.tabs selectTabViewItemAtIndex:1];
}

- (IBAction)onGotoUserInfoClick:(id)sender {
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString *myUserName = [defaults stringForKey:Preference_Key_StatusNet_UserName];
    if (myUserName != nil && ![myUserName isEqualToString:@""]) {
        NSDictionary *userInfo= [[NSDictionary alloc] initWithObjectsAndKeys:
                                 myUserName, @"UserName", nil];
        [AMN_NOTIFICATION_MANAGER postMessage:userInfo withTypeName:AMN_SHOWUSERINFO source:self];
    }else{
        [self PopoverUserLogonView:sender];
    }
}

-(void)PopoverUserLogonView:(id)sender
{
    if (self.myPopover == nil) {
        self.myPopover = [[NSPopover alloc] init];
        
        self.myPopover.animates = YES;
        self.myPopover.behavior = NSPopoverBehaviorTransient;
        self.myPopover.appearance = NSPopoverAppearanceHUD;
        self.myPopover.delegate = self;
    }
    
    self.myPopover.contentViewController = [[AMUserLogonViewController alloc] initWithNibName:@"AMUserLogonViewController" bundle:nil];
    
    NSButton *targetButton = (NSButton*)sender;
    NSRectEdge prefEdge = NSMaxXEdge;
    [self.myPopover showRelativeToRect:[targetButton bounds] ofView:sender preferredEdge:prefEdge];
}

- (IBAction)groupSocialBtnClicked:(NSButton *)sender
{
    NSString* groupName = self.groupNameField.stringValue;
    
    for (AMStaticGroup* sg in [AMCoreData shareInstance].staticGroups) {
        if ([sg.nickname isEqualToString:groupName]) {
            NSDictionary *userInfo= [[NSDictionary alloc] initWithObjectsAndKeys:
                                     groupName, @"GroupName", nil];
            [AMN_NOTIFICATION_MANAGER postMessage:userInfo withTypeName:AMN_SHOWGROUPINFO source:self];
            return;
        }
    }
    
    [self popoverGroupRegisterView:sender];

}

-(void)popoverGroupRegisterView:(id)sender
{
    if (self.myPopover == nil) {
        self.myPopover = [[NSPopover alloc] init];
        
        self.myPopover.animates = YES;
        self.myPopover.behavior = NSPopoverBehaviorTransient;
        self.myPopover.appearance = NSPopoverAppearanceHUD;
        self.myPopover.delegate = self;
    }
    
    self.myPopover.contentViewController = [[AMGroupCreateViewController alloc] initWithNibName:@"AMGroupCreateViewController" bundle:nil];
    
    NSButton *targetButton = (NSButton*)sender;
    NSRectEdge prefEdge = NSMaxXEdge;
    [self.myPopover showRelativeToRect:[targetButton bounds] ofView:sender preferredEdge:prefEdge];
}

- (IBAction)groupNameEdited:(NSTextField *)sender
{
    if ([sender.stringValue isEqualTo:@""]) {
        return;
    }
    
    AMLiveGroup* group = [AMCoreData shareInstance].myLocalLiveGroup;
    group.groupName = sender.stringValue;
    [[AMMesher sharedAMMesher] updateGroup];
}

- (IBAction)groupDescriptionEdited:(NSTextField *)sender
{
    if ([sender.stringValue isEqualTo:@""]) {
        return;
    }
    
    AMLiveGroup* group = [AMCoreData shareInstance].myLocalLiveGroup;
    group.description = sender.stringValue;
    [[AMMesher sharedAMMesher] updateGroup];
}

- (IBAction)groupFullNameEdited:(NSTextField *)sender
{
    if ([sender.stringValue isEqualTo:@""]) {
        return;
    }
    
    AMLiveGroup* group = [AMCoreData shareInstance].myLocalLiveGroup;
    group.fullName = sender.stringValue;
    [[AMMesher sharedAMMesher] updateGroup];
}

- (IBAction)groupProjetctEdited:(NSTextField *)sender
{
    if ([sender.stringValue isEqualTo:@""]) {
        return;
    }
    
    AMLiveGroup* group = [AMCoreData shareInstance].myLocalLiveGroup;
    group.project= sender.stringValue;
    [[AMMesher sharedAMMesher] updateGroup];
}

- (IBAction)groupLocationEdited:(NSTextField *)sender
{
    if ([sender.stringValue isEqualTo:@""]) {
        return;
    }
    
    AMLiveGroup* group = [AMCoreData shareInstance].myLocalLiveGroup;
    group.location= sender.stringValue;
    [[AMMesher sharedAMMesher] updateGroup];
}

-(void)onChecked:(AMCheckBoxView*)sender
{
    if(sender.checked){
        if(sender == self.groupBusyCheckbox){
            [self setGroupBusy:YES];
        }else if(sender == self.userBusyCheckBox){
            [self setUserBusy:YES];
        }
    }else{
        if(sender == self.groupBusyCheckbox){
            [self setGroupBusy:NO];
        }else if(sender == self.userBusyCheckBox){
            [self setUserBusy:NO];
        }
    }
}

-(void)setUserBusy:(BOOL)busy
{
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    
    if (mySelf.isOnline) {
        mySelf.busy = busy;
        [[AMMesher sharedAMMesher] updateMySelf];
    }

}


-(void)setGroupBusy:(BOOL)busy
{
    AMLiveGroup* group = [AMCoreData shareInstance].myLocalLiveGroup;
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    if (mySelf.isOnline) {
        group.busy = busy;
        [[AMMesher sharedAMMesher] updateGroup];
    }
}

- (void)popoverWillShow:(NSNotification *)notification
{
    if ([self.myPopover.contentViewController isKindOfClass:[AMUserLogonViewController class]]) {
        AMUserLogonViewController* popController = (AMUserLogonViewController*)self.myPopover.contentViewController;
        if (popController != nil) {
            
            AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
            popController.nickName = mySelf.nickName;
        }
    }else if([self.myPopover.contentViewController isKindOfClass:[AMGroupCreateViewController class]]){
        AMGroupCreateViewController* popController = (AMGroupCreateViewController*)self.myPopover.contentViewController;
        if (popController != nil) {
            
            NSUserDefaults* defaults = [AMPreferenceManager standardUserDefaults];
            NSString* groupname = [defaults stringForKey:Preference_Key_Cluster_Name];
            popController.nickName = groupname;
        }
    }
    
   
}

-(void)popoverDidClose:(NSNotification *)notification
{
    [self loadUserAvatar];
}

- (IBAction)nickNameChanged:(id)sender
{
    NSString* nickName = self.nickNameField.stringValue;
    if ([nickName isEqualToString:@""]) {
        nickName = [[AMPreferenceManager standardUserDefaults]
                                 stringForKey:Preference_Key_User_NickName];
        
        self.nickNameField.stringValue = nickName;
    }
    
    //update AMCoreData
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    mySelf.nickName = nickName;
    [[AMMesher sharedAMMesher] updateMySelf];
    
}

- (IBAction)fullNameChanged:(id)sender
{
    NSString* fullName = self.fullNameField.stringValue;
    if ([fullName isEqualToString:@""]) {
        fullName = [[AMPreferenceManager standardUserDefaults]
                                 stringForKey:Preference_Key_User_FullName];
        
        self.fullNameField.stringValue = fullName;
    }
    
    //update AMCoreData
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    mySelf.fullName = fullName;
    [[AMMesher sharedAMMesher] updateMySelf];
}

- (IBAction)locationChanged:(id)sender
{
    NSString* location = self.locationField.stringValue;
    if ([location isEqualToString:@""]) {
        
        location = [[AMPreferenceManager standardUserDefaults]
                                     stringForKey:Preference_Key_User_Location];
    
        self.locationField.stringValue = location;
    }
    
    //update AMCoreData
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    mySelf.location = location;
    [[AMMesher sharedAMMesher] updateMySelf];
    
}

- (IBAction)affiliationChanged:(id)sender
{
    NSString* affilication = self.affiliationField.stringValue;
    if ([affilication isEqualToString:@""]) {
        
        affilication = [[AMPreferenceManager standardUserDefaults]
                                     stringForKey:Preference_Key_User_Affiliation];
        
        self.affiliationField.stringValue = affilication;
    }
    
    //update AMCoreData
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    mySelf.domain = affilication;
    [[AMMesher sharedAMMesher] updateMySelf];
    
}

- (IBAction)biographyChanged:(id)sender
{
    NSString* biography = self.biographyField.stringValue;
    if ([biography isEqualToString:@""]) {
        
        biography = [[AMPreferenceManager standardUserDefaults]
                                stringForKey:Preference_Key_User_Description];
        
        self.biographyField.stringValue = biography;
    }
    
    //update AMCoreData
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    mySelf.description = biography;
    [[AMMesher sharedAMMesher] updateMySelf];
    
}

@end
