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

#import "AMGeneralSettingsVC.h"
#import "UIFramework/AMPopUpView.h"
#import "UIFramework/AMCheckBoxView.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "AMCommonTools/AMCommonTools.h"
#import "AMCoreData/AMCoreData.h"
#import "AMAppDelegate.h"

#import <GTL/GTMOAuth2WindowController.h>
#import "GTLYouTube.h"


@interface AMBroadcastViewController : AMTabPanelViewController {
    @private GTMOAuth2Authentication *mAuth;
}

@property (strong) IBOutlet NSButton *settingsBtn;
@property (strong) IBOutlet NSButton *youtubeBtn;
@property (strong) IBOutlet NSTabView *groupTabView;
@property (strong) IBOutlet NSButton *oAuthSignInBtn;
@property (strong) IBOutlet NSButton *createEventBtn;
@property (strong) IBOutlet NSTextField *broadcastTItleField;
@property (strong) IBOutlet NSTextField *broadcastDescField;
@property (strong) IBOutlet AMPopUpView *broadcastStartTimeField;
@property (strong) IBOutlet AMPopUpView *broadcastEndTimeField;


@property (strong) IBOutlet NSTextField *eventStartDayTextField;
@property (strong) IBOutlet NSTextField *eventStartMonthTextField;
@property (strong) IBOutlet NSTextField *eventStartYearTextField;
@property (strong) IBOutlet NSTextField *eventStartHourTextField;
@property (strong) IBOutlet NSTextField *eventStartMinuteTextField;


@property (strong) IBOutlet NSTextField *eventEndDayTextField;
@property (strong) IBOutlet NSTextField *eventEndMonthTextField;
@property (strong) IBOutlet NSTextField *eventEndYearTextField;
@property (strong) IBOutlet NSTextField *eventEndHourTextField;
@property (strong) IBOutlet NSTextField *eventEndMinuteTextField;

@property (strong) IBOutlet NSTextField *eventFeedbackTextField;

@property (strong) IBOutlet AMPopUpView *eventEndTimeDropDown;
@property (strong) IBOutlet AMCheckBoxView *privateCheck;


- (void)changeBroadcastURL : (NSString *)newURL;
- (IBAction)youtubeBtnClick:(id)sender;
- (IBAction)settingsBtnClick:(id)sender;
- (IBAction)oAuthSignInBtnClick:(id)sender;

- (BOOL)isSignedIn;

@end
