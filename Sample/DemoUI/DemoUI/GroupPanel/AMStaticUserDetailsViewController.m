//
//  AMStaticUserDetailsViewController.m
//  DemoUI
//
//  Created by Wei Wang on 7/22/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMStaticUserDetailsViewController.h"
#import <UIFramework/AMFoundryFontView.h>
#import "AMGroupPanelModel.h"
#import "UIFramework/AMButtonHandler.h"
#import "AMMesher/AMMesher.h"
#import "AMPreferenceManager/AMPreferenceManager.h"

@interface AMStaticUserDetailsViewController ()
@property (weak) IBOutlet AMFoundryFontView *userName;
@property (weak) IBOutlet AMFoundryFontView *location;
@property (weak) IBOutlet AMFoundryFontView *timeZone;
@property (unsafe_unretained) IBOutlet NSTextView *homepage;
@property (unsafe_unretained) IBOutlet NSTextView *description;
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
    
    if (self.homepage && self.staticUser.url) {
        NSFont* textViewFont =  [NSFont fontWithName: @"FoundryMonoline-Bold" size: self.homepage.font.pointSize];
        NSDictionary* attr = @{NSForegroundColorAttributeName: [NSColor whiteColor],
                               NSFontAttributeName:textViewFont};
        NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:self.staticUser.url attributes:attr];
        [self.homepage.textStorage appendAttributedString:attrStr];
        [self.homepage setNeedsDisplay:YES];
    }
    
    if (self.description && self.staticUser.description) {
        NSFont* textViewFont =  [NSFont fontWithName: @"FoundryMonoline-Bold" size: self.description.font.pointSize];
        NSDictionary* attr = @{NSForegroundColorAttributeName: [NSColor whiteColor],
                               NSFontAttributeName:textViewFont};
        NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:self.staticUser.description attributes:attr];
        [self.description.textStorage appendAttributedString:attrStr];
        [self.description setNeedsDisplay:YES];
    }
}

- (IBAction)closeBtnClicked:(NSButton *)sender
{
    AMGroupPanelModel* model = [AMGroupPanelModel sharedGroupModel];
    model.detailPanelState = DetailPanelHide;
}

- (IBAction)applyBtnClicked:(NSButton *)sender
{
     NSUserDefaults* defaults = [AMPreferenceManager standardUserDefaults];
    [AMCoreData shareInstance].mySelf.nickName = self.userName.stringValue;
    [AMCoreData shareInstance].mySelf.description = self.description.textStorage.string;
    [AMCoreData shareInstance].mySelf.location = self.location.stringValue;
    
    [defaults setObject:self.userName.stringValue forKey:Preference_Key_User_NickName];
    [defaults setObject:self.description.textStorage.string forKey:Preference_Key_User_Description];
    [defaults setObject:self.location.stringValue forKey:Preference_Key_User_Location];
    
    [[AMMesher sharedAMMesher] updateMySelf];
    [[AMGroupPanelModel sharedGroupModel] setDetailPanelState:DetailPanelHide];

}

@end
