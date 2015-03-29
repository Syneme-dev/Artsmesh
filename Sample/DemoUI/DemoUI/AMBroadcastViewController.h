//
//  AMGPlusViewController.h
//  DemoUI
//
//  Created by Wei Wang on 8/11/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "AMTabPanelViewController.h"
#import <GTL/GTMOAuth2WindowController.h>

#import "AMGeneralSettingsVC.h"
#import "UIFramework/AMPopUpView.h"
#import "UIFramework/AMCheckBoxView.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "AMCommonTools/AMCommonTools.h"
#import "AMCoreData/AMCoreData.h"
#import "AMAppDelegate.h"


@interface AMBroadcastViewController : AMTabPanelViewController {
    @private GTMOAuth2Authentication *mAuth;
}

@property (strong) IBOutlet NSButton *settingsBtn;
@property (strong) IBOutlet NSButton *youtubeBtn;
@property (strong) IBOutlet NSTabView *groupTabView;
@property (strong) IBOutlet NSButton *oAuthSignInBtn;
@property (strong) IBOutlet AMPopUpView *eventStartTimeDropDown;
@property (strong) IBOutlet AMPopUpView *eventEndTimeDropDown;
@property (strong) IBOutlet AMCheckBoxView *privateCheck;


- (void)changeBroadcastURL : (NSString *)newURL;
- (IBAction)youtubeBtnClick:(id)sender;
- (IBAction)settingsBtnClick:(id)sender;
- (IBAction)oAuthSignInBtnClick:(id)sender;

- (BOOL)isSignedIn;

@end
