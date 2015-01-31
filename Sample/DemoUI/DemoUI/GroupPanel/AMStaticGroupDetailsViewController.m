//
//  AMStaticGroupDetailsViewController.m
//  DemoUI
//
//  Created by Wei Wang on 7/11/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMStaticGroupDetailsViewController.h"
#import "UIFramework/AMFoundryFontTextView.h"
#import "UIFramework/AMButtonHandler.h"
#import "UIFramework/AMFoundryFontView.h"
#import "AMMesher/AMMesher.h"
#import "AMPreferenceManager/AMPreferenceManager.h"

#define UI_Color_b7b7b7  [NSColor colorWithCalibratedRed:(168)/255.0f green:(168)/255.0f blue:(168)/255.0f alpha:1.0f]
@interface AMStaticGroupDetailsViewController ()

@property (unsafe_unretained) IBOutlet NSTextView *homepageView;
@property (unsafe_unretained) IBOutlet AMFoundryFontTextView *descriptionView;
@property (weak) IBOutlet NSButton *closeBtn;
@property (weak) IBOutlet NSButton *applyBtn;
@property (weak) IBOutlet AMFoundryFontView *groupNameField;


@end

@implementation AMStaticGroupDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (IBAction)closeBtnClick:(NSButton *)sender {
    if (self.hostVC) {
        [self.hostVC resignDetailView:self];
    }
}

-(void)awakeFromNib
{
    [AMButtonHandler changeTabTextColor:self.closeBtn toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.applyBtn toColor:UI_Color_blue];
    
    if (self.staticGroup.nickname != nil) {
        
    }
    
    if (![self.staticGroup.homepage isEqualTo:[NSNull null]]) {
        NSFont* textViewFont =  [NSFont fontWithName: @"FoundryMonoline" size: self.homepageView.font.pointSize];
        NSDictionary* attr = @{NSForegroundColorAttributeName: [NSColor whiteColor],
                               NSFontAttributeName:textViewFont};
        NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:self.staticGroup.homepage attributes:attr];
        [self.homepageView.textStorage appendAttributedString:attrStr];
        [self.homepageView setNeedsDisplay:YES];
    }

    if (![self.staticGroup.description isEqualTo:[NSNull null]]) {
        NSFont* textViewFont =  [NSFont fontWithName: @"FoundryMonoline" size: self.descriptionView.font.pointSize];
        NSDictionary* attr = @{NSForegroundColorAttributeName: [NSColor whiteColor],
                               NSFontAttributeName:textViewFont};
        NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:self.staticGroup.description attributes:attr];
        [self.descriptionView.textStorage appendAttributedString:attrStr];
        [self.descriptionView setNeedsDisplay:YES];
    }
    

    [self.applyBtn setEnabled:NO];
    NSArray* myGroups = [AMCoreData shareInstance].myStaticGroups;
    for (AMStaticGroup* sg in myGroups) {
        if ([sg.g_id intValue] == [self.staticGroup.g_id intValue]) {
            [self.applyBtn setEnabled:YES];
        }
    }
}

- (IBAction)applyBtnClicked:(NSButton *)sender
{
    NSUserDefaults* defaults = [AMPreferenceManager standardUserDefaults];
    
    [AMCoreData shareInstance].myLocalLiveGroup.groupName = self.staticGroup.nickname;
    [AMCoreData shareInstance].myLocalLiveGroup.description = self.staticGroup.description;
    [AMCoreData shareInstance].myLocalLiveGroup.location = self.staticGroup.location;
    [AMCoreData shareInstance].myLocalLiveGroup.fullName = self.staticGroup.fullname;
    [AMCoreData shareInstance].myLocalLiveGroup.homePage = self.staticGroup.homepage;
    
    if ([self.staticGroup.nickname isNotEqualTo:[NSNull null]]) {
         [defaults setObject:self.staticGroup.nickname forKey:Preference_Key_Cluster_Name];
    }
    
    if ([self.staticGroup.description isNotEqualTo:[NSNull null]]) {
        [defaults setObject:self.staticGroup.description forKey:Preference_Key_Cluster_Description];
    }
    
    if ([self.staticGroup.location isNotEqualTo:[NSNull null]]) {
        [defaults setObject:self.staticGroup.location forKey:Preference_Key_Cluster_Location];
    }
    
    if ([self.staticGroup.fullname isNotEqualTo:[NSNull null]]) {
        [defaults setObject:self.staticGroup.fullname forKey:Preference_Key_Cluster_FullName];
    }
    
    if ([self.staticGroup.homepage isNotEqualTo:[NSNull null]]) {
        [defaults setObject:self.staticGroup.homepage forKey:Preference_Key_Cluster_HomePage];
    }
    
    [[AMMesher sharedAMMesher] updateGroup];
    [self.closeBtn performClick:nil];
}


@end
