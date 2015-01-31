//
//  AMStaticUserDetailsViewController.m
//  DemoUI
//
//  Created by Wei Wang on 7/22/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMStaticUserDetailsViewController.h"
#import <UIFramework/AMFoundryFontView.h>

#import "UIFramework/AMButtonHandler.h"
#import "AMMesher/AMMesher.h"
#import "AMPreferenceManager/AMPreferenceManager.h"

@interface AMStaticUserDetailsViewController ()
@property (weak) IBOutlet AMFoundryFontView *userName;
@property (weak) IBOutlet AMFoundryFontView *location;
@property (weak) IBOutlet AMFoundryFontView *timeZone;
@property (unsafe_unretained) IBOutlet NSTextView *homepage;
@property (unsafe_unretained) IBOutlet NSTextView *descriptionView;
@property (weak) IBOutlet NSButton *clostBtn;
@property (weak) IBOutlet NSButton *applyBtn;

@end

@implementation AMStaticUserDetailsViewController

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
    [AMButtonHandler changeTabTextColor:self.clostBtn toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.applyBtn toColor:UI_Color_blue];
    
    if (![self.staticUser.url isEqualTo:[NSNull null]]) {
        NSFont* textViewFont =  [NSFont fontWithName: @"FoundryMonoline" size: self.homepage.font.pointSize];
        NSDictionary* attr = @{NSForegroundColorAttributeName: [NSColor whiteColor],
                               NSFontAttributeName:textViewFont};
        NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:self.staticUser.url attributes:attr];
        [self.homepage.textStorage appendAttributedString:attrStr];
        [self.homepage setNeedsDisplay:YES];
    }
    
    if (![self.staticUser.description isEqualTo:[NSNull null]]) {
        NSFont* textViewFont =  [NSFont fontWithName: @"FoundryMonoline" size: self.descriptionView.font.pointSize];
        NSDictionary* attr = @{NSForegroundColorAttributeName: [NSColor whiteColor],
                               NSFontAttributeName:textViewFont};
        NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:self.staticUser.description attributes:attr];
        [self.descriptionView.textStorage appendAttributedString:attrStr];
        [self.descriptionView setNeedsDisplay:YES];
    }
    
    NSUserDefaults* defaults = [AMPreferenceManager standardUserDefaults];
    NSString* myNickName = [defaults stringForKey:Preference_Key_StatusNet_UserName];
    if ([self.staticUser.name isEqualToString:myNickName]) {
        [self.applyBtn setEnabled:YES];
    }else{
        [self.applyBtn setEnabled:NO];
    }
    
}

- (IBAction)closeBtnClicked:(NSButton *)sender
{
    if (self.hostVC) {
        [self.hostVC resignDetailView:self];
    }
}

- (IBAction)applyBtnClicked:(NSButton *)sender
{
     NSUserDefaults* defaults = [AMPreferenceManager standardUserDefaults];
    [AMCoreData shareInstance].mySelf.nickName = self.staticUser.name;
    [AMCoreData shareInstance].mySelf.description = self.staticUser.description;
    [AMCoreData shareInstance].mySelf.location = self.staticUser.location;
    
    [defaults setObject:self.userName.stringValue forKey:Preference_Key_User_NickName];
    [defaults setObject:self.descriptionView.textStorage.string forKey:Preference_Key_User_Description];
    [defaults setObject:self.location.stringValue forKey:Preference_Key_User_Location];
    
    [[AMMesher sharedAMMesher] updateMySelf];
    
    [self.clostBtn performClick:nil];
}

@end
