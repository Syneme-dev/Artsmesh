//
//  AMUserProfielViewController.m
//  DemoUI
//
//  Created by 王为 on 23/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMUserProfielViewController.h"
#import "UIFramework/AMCheckBoxView.h"
#import "UIFramework/AMFoundryFontView.h"
#import "AMCoreData/AMCoredata.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "AMStatusNet/AMStatusNet.h"
#import "AMMesher/AMMesher.h"
#import "AMNotificationManager/AMNotificationManager.h"
#import "AMUserLogonViewController.h"

@interface AMUserProfielViewController ()<AMCheckBoxDelegeate,NSPopoverDelegate>
@property (weak) IBOutlet NSImageView *userAvatar;
@property (weak) IBOutlet AMCheckBoxView *userBusyCheck;
@property (weak) IBOutlet AMFoundryFontView *nickNameField;
@property (weak) IBOutlet AMFoundryFontView *fullNameField;
@property (weak) IBOutlet AMFoundryFontView *affiliationField;
@property (weak) IBOutlet AMFoundryFontView *localtionField;
@property (weak) IBOutlet AMFoundryFontView *biographyField;
@property (weak) IBOutlet NSImageView *userStatus;

@property NSPopover *myPopover;

@end

@implementation AMUserProfielViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self loadAvatar];
    [self setBusyBox];
    [self setStatus];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mySelfChanged:) name:AM_MYSELF_CHANGED_LOCAL object:nil];

}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



-(void)loadAvatar
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString * myUserName = [defaults stringForKey:Preference_Key_StatusNet_UserName];
    
    [[AMStatusNet shareInstance] loadUserAvatar:myUserName requestCallback:^(NSImage* image, NSError* err){
        if (err != nil) {
            return;
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.userAvatar setImage:image];
            });
        }
    }];
}


-(void)setBusyBox
{
    self.userBusyCheck.title = @"BUSY";
    self.userBusyCheck.delegate = self;
    
    AMLiveUser *mySelf = [AMCoreData shareInstance].mySelf;
    if (mySelf.busy) {
        self.userBusyCheck.checked = YES;
    }else{
        self.userBusyCheck.checked = NO;
    }
}


-(void)setStatus
{
    AMLiveUser *mySelf = [AMCoreData shareInstance].mySelf;
    if (mySelf.busy) {
        [self.userStatus setImage:[NSImage imageNamed:@"groupuser_busy"]];
    }else if(mySelf.isOnline){
        [self.userStatus setImage:[NSImage imageNamed:@"groupuser_meshed_icon"]];
    }else{
        [self.userStatus setImage:[NSImage imageNamed:@"user_unmeshed_icon"]];
    }
}


- (IBAction)nickNameChanged:(id)sender
{
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    NSString* nickName = self.nickNameField.stringValue;
    
    if([mySelf.nickName isEqualTo:nickName]){
        return;
    }
    
    if ([nickName isEqualToString:@""]) {
        nickName = [[AMPreferenceManager standardUserDefaults]
                    stringForKey:Preference_Key_User_NickName];
        
        self.nickNameField.stringValue = nickName;
    }

    mySelf.nickName = nickName;
    [[AMMesher sharedAMMesher] updateMySelf];
    
    [self startBlickingStatus];
}


- (IBAction)fullNameChanged:(id)sender
{
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    NSString* fullName = self.fullNameField.stringValue;
    
    if ([mySelf.fullName isEqualTo:fullName]) {
        return;
    }
    
    if ([fullName isEqualToString:@""]) {
        fullName = [[AMPreferenceManager standardUserDefaults]
                    stringForKey:Preference_Key_User_FullName];
        
        self.fullNameField.stringValue = fullName;
    }
    
    mySelf.fullName = fullName;
    [[AMMesher sharedAMMesher] updateMySelf];
    
    [self startBlickingStatus];

}


- (IBAction)affiliationChanged:(id)sender
{
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    NSString* affilication = self.affiliationField.stringValue;
    
    if ([mySelf.domain isEqualTo:affilication]) {
        return;
    }
    
    if ([affilication isEqualToString:@""]) {
        
        affilication = [[AMPreferenceManager standardUserDefaults]
                        stringForKey:Preference_Key_User_Affiliation];
        
        self.affiliationField.stringValue = affilication;
    }
    
    mySelf.domain = affilication;
    [[AMMesher sharedAMMesher] updateMySelf];
    
    [self startBlickingStatus];
}


- (IBAction)locationChanged:(id)sender
{
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    NSString* location = self.localtionField.stringValue;
    
    if ([mySelf.location isEqualTo:location]) {
        return;
    }
    
    if ([location isEqualToString:@""]) {
        
        location = [[AMPreferenceManager standardUserDefaults]
                    stringForKey:Preference_Key_User_Location];
        
        self.localtionField.stringValue = location;
    }
    
    mySelf.location = location;
    [[AMMesher sharedAMMesher] updateMySelf];
    
    [self startBlickingStatus];

}


- (IBAction)biographyChanged:(id)sender
{
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    NSString* biography = self.biographyField.stringValue;
    
    if ([mySelf.description isEqualTo:biography]) {
        return;
    }
    
    if ([biography isEqualToString:@""]) {
        
        biography = [[AMPreferenceManager standardUserDefaults]
                     stringForKey:Preference_Key_User_Description];
        
        self.biographyField.stringValue = biography;
    }
    
    mySelf.description = biography;
    [[AMMesher sharedAMMesher] updateMySelf];
    
    [self startBlickingStatus];
}


-(void)onChecked:(AMCheckBoxView*)sender
{
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    mySelf.busy = sender.checked;
    
    [[AMMesher sharedAMMesher] updateMySelf];
    [self startBlickingStatus];
}


-(void)startBlickingStatus
{
    [self.userStatus setImage:[NSImage imageNamed:@"synchronizing_icon"]];
    [self performSelector:@selector(setStatus) withObject:nil afterDelay:1];
}


-(void)mySelfChanged:(NSNotification *)notification
{
    [self setStatus];
    [self loadAvatar];
    [self setBusyBox];
}

- (IBAction)socialBtnClick:(id)sender
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString *myUserName = [defaults stringForKey:Preference_Key_StatusNet_UserName];
    NSString *profileUrl = [NSString stringWithFormat:@"/%@", myUserName];
    if (myUserName != nil && ![myUserName isEqualToString:@""]) {
        NSDictionary *userInfo= [[NSDictionary alloc] initWithObjectsAndKeys:
                                 profileUrl, @"ProfileUrl", nil];
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


- (void)popoverWillShow:(NSNotification *)notification
{
    if ([self.myPopover.contentViewController isKindOfClass:[AMUserLogonViewController class]]) {
        AMUserLogonViewController* popController = (AMUserLogonViewController*)self.myPopover.contentViewController;
        if (popController != nil) {
            
            AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
            popController.nickName = mySelf.nickName;
        }
    }
}


-(void)popoverDidClose:(NSNotification *)notification
{
    [self loadAvatar];
}

@end
