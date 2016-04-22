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

#import "AMStandardButton.h"
#import "AMGeneralSettingsVC.h"
#import "UIFramework/AMPopUpView.h"
#import "UIFramework/AMCheckBoxView.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "AMCommonTools/AMCommonTools.h"
#import "AMCoreData/AMCoreData.h"
#import "AMAppDelegate.h"
#import "AMEventsManagerViewController.h"
#import "AMFFMpegConfigs.h"
#import "AMFFMpeg.h"

#import <GTL/GTMOAuth2WindowController.h>
#import "GTLYouTube.h"


@interface AMVideoSettingsVC : AMTabPanelViewController {
    @private GTMOAuth2Authentication *mAuth;
}

@property (strong) GTLYouTubeLiveBroadcast *selectedBroadcast;
@property (strong) GTLYouTubeLiveStream *selectedStream;

// YouTube Tab IBOutlets
@property (strong) IBOutlet NSTabView *groupTabView;


// Settings Tab IBOutlets
@property (strong) IBOutlet AMPopUpView *videoDevicePopupView;
//@property (strong) IBOutlet AMPopUpView *videoInputSizePopupView;
@property (strong) IBOutlet AMPopUpView *videoFormatPopupView;
@property (strong) IBOutlet AMPopUpView *videoFrameRatePopupView;
@property (strong) IBOutlet NSTextField *videoBitRateTextField;
@property (strong) IBOutlet AMPopUpView *videoOutputSizePopupView;


@property (strong) IBOutlet AMPopUpView *audioDevicePopupView;
@property (strong) IBOutlet AMPopUpView *audioFormatPopupView;
@property (strong) IBOutlet AMPopUpView *audioSampleRatePopupView;
@property (strong) IBOutlet AMPopUpView *audioBitRatePopupView;
@property (strong) IBOutlet NSTextField *baseUrlTextField;
@property (strong) IBOutlet NSTextField *streamKeyTextField;

@property (strong) IBOutlet AMStandardButton *settingsCancelBtn;
@property (strong) IBOutlet AMStandardButton *settingsSaveBtn;
@property (strong) IBOutlet AMStandardButton *settingsRefreshBtn;




// Global IBActions

- (BOOL)isSignedIn;


- (void)changeBroadcastURL : (NSString *)newURL;

@end
