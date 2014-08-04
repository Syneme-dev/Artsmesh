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

@interface AMUserViewController ()<AMCheckBoxDelegeate, NSPopoverDelegate>
@property (weak) IBOutlet AMCheckBoxView *groupBusyCheckbox;
@property (weak) IBOutlet AMCheckBoxView *userBusyCheckBox;
@property (weak) IBOutlet NSImageView *userStatusIcon;
@property (weak) IBOutlet NSImageView *groupStatusIcon;

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
    [self loadAvatarImage];
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
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    if(mySelf.isOnline == YES) {
        return;
    }
    
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
    
    [self.userStatusIcon setImage:[NSImage imageNamed:@"user_unmeshed_icon"]];
}

-(void)registerTabButtons{
    super.tabs=self.tabs;
    self.tabButtons =[[NSMutableArray alloc]init];
    [self.tabButtons addObject:self.userTabButton];
    [self.tabButtons addObject:self.groupTabButton];
    self.showingTabsCount=2;
    
}
//Note:sample code if using this as notification.
//-(void)onUpdateUserAVator:(NSNotification*)notification{
//    
//
//    NSDictionary* user=notification.userInfo;
//    NSString *imageUrlString=[user valueForKey:@"profile_image_url"];
//    NSURL* imageUrl=[NSURL URLWithString:[imageUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    NSData *imageData = [imageUrl resourceDataUsingCache:NO];
//    NSImage *imageFromBundle = [[NSImage alloc] initWithData:imageData];
//    [self.avatarView  setImage:imageFromBundle];
//    
////http://artsmesh.io//theme/dark/default-avatar-profile.png
//}

-(void)loadAvatarImage{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *myAccountUrl=[AMRestHelper getMyAccountInfoUrl];
    [manager GET:myAccountUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *imageUrlString=[responseObject valueForKey:@"profile_image_url"];
        [self loadAvatarFromUrl:imageUrlString];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [self loadAvatarFromUrl:@"http://artsmesh.io//theme/dark/default-avatar-profile.png"];
    }];
}

-(void)loadAvatarFromUrl:(NSString*)imageUrlString{
    NSURL* imageUrl=[NSURL URLWithString:[imageUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *imageData = [imageUrl resourceDataUsingCache:NO];
    NSImage *imageFromBundle = [[NSImage alloc] initWithData:imageData];
    [self.avatarView  setImage:imageFromBundle];
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

- (IBAction)nicknameEdited:(NSTextField *)sender
{
    if ([sender.stringValue isEqualTo:@""]) {
        return;
    }
    
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    mySelf.nickName = sender.stringValue;
    [[AMMesher sharedAMMesher] updateMySelf];
}

- (IBAction)locationEdited:(NSTextField *)sender
{
    if ([sender.stringValue isEqualTo:@""]) {
        return;
    }
    
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    mySelf.location = sender.stringValue;
    [[AMMesher sharedAMMesher] updateMySelf];
}

- (IBAction)statusMessageEdited:(NSTextField *)sender
{
    if ([sender.stringValue isEqualTo:@""]) {
        return;
    }
    
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    mySelf.description = sender.stringValue;
    [[AMMesher sharedAMMesher] updateMySelf];
}

- (IBAction)domainEdited:(NSTextField *)sender
{
    if ([sender.stringValue isEqualTo:@""]) {
        return;
    }
    
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    mySelf.domain = sender.stringValue;
    [[AMMesher sharedAMMesher] updateMySelf];
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
    AMUserLogonViewController* popController = (AMUserLogonViewController*)self.myPopover.contentViewController;
    if (popController != nil) {
        
        AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
        popController.nickName = mySelf.nickName;
    }
}

@end
