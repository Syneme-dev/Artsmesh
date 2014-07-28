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

@interface AMUserViewController ()

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
    [self loadAvatarImage];
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
@end
