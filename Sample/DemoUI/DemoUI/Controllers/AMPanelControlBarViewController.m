//
//  AMPanelControlBarViewController.m
//  DemoUI
//
//  Created by xujian on 7/23/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMPanelControlBarViewController.h"
#import "AMAppDelegate.h"

@interface AMPanelControlBarViewController ()

@end

@implementation AMPanelControlBarViewController

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
    _curTheme = [AMTheme sharedInstance];
    [self setButtonImages:_curTheme];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changeTheme:)
                                                 name:@"AMThemeChanged"
                                               object:nil];
}

- (IBAction)onSidebarDoubleClick:(NSButton *)sender {
     AMAppDelegate *appDelegate=AM_APPDELEGATE;
    NSString *panelId=
    [[NSString stringWithFormat:@"%@_PANEL",sender.identifier ] uppercaseString];
    AMPanelViewController *panelViewController = appDelegate.mainWindowController.panelControllers [panelId];
    if(panelViewController!=nil){
        [appDelegate.mainWindowController.mainScrollView.contentView scrollToPoint:panelViewController.view.frame.origin];
    }
}

- (IBAction)onSidebarItemClick:(NSButton *)sender {

    AMAppDelegate *appDelegate=AM_APPDELEGATE;
    NSString *panelId=
    [[NSString stringWithFormat:@"%@_PANEL",sender.identifier ] uppercaseString];
    if(sender.state==NSOnState)
    {
        [appDelegate.mainWindowController createPanelWithType:panelId withId:panelId];
    }
    else
    {
       
        [appDelegate.mainWindowController  removePanel:panelId];
    }
}

- (void)setButtonImages:(AMTheme *)theme {
    
    //Help/Manual Buttons
    [self.panelHelpBtn setImage:theme.imagePanelBtnManual];
    [self.panelHelpBtn setAlternateImage:theme.imagePanelBtnManualAlt];
    [self.panelHelpBtnSidebar setImage:theme.imagePanelBtnManual];
    [self.panelHelpBtnSidebar setAlternateImage:theme.imagePanelBtnManualAlt];
    
    //User Buttons
    [self.panelUserBtn setImage:theme.imagePanelBtnUser];
    [self.panelUserBtn setAlternateImage:theme.imagePanelBtnUserAlt];
    [self.panelUserBtnSidebar setImage:theme.imagePanelBtnUser];
    [self.panelUserBtnSidebar setAlternateImage:theme.imagePanelBtnUserAlt];
    
    //Group Buttons
    [self.panelGroupBtn setImage:theme.imagePanelBtnGroup];
    [self.panelGroupBtn setAlternateImage:theme.imagePanelBtnGroupAlt];
    [self.panelGroupBtnSidebar setImage:theme.imagePanelBtnGroup];
    [self.panelGroupBtnSidebar setAlternateImage:theme.imagePanelBtnGroupAlt];
    
    //Chat Buttons
    [self.panelChatBtn setImage:theme.imagePanelBtnChat];
    [self.panelChatBtn setAlternateImage:theme.imagePanelBtnChatAlt];
    [self.panelChatBtnSidebar setImage:theme.imagePanelBtnChat];
    [self.panelChatBtnSidebar setAlternateImage:theme.imagePanelBtnChatAlt];
    
    //Social Buttons
    [self.panelSocialBtn setImage:theme.imagePanelBtnSocial];
    [self.panelSocialBtn setAlternateImage:theme.imagePanelBtnSocialAlt];
    [self.panelSocialBtnSidebar setImage:theme.imagePanelBtnSocial];
    [self.panelSocialBtnSidebar setAlternateImage:theme.imagePanelBtnSocialAlt];
    
    //Map Buttons
    [self.panelMapBtn setImage:theme.imagePanelBtnMap];
    [self.panelMapBtn setAlternateImage:theme.imagePanelBtnMapAlt];
    [self.panelMapBtnSidebar setImage:theme.imagePanelBtnMap];
    [self.panelMapBtnSidebar setAlternateImage:theme.imagePanelBtnMapAlt];
    
    //Route Buttons
    [self.panelRouteBtn setImage:theme.imagePanelBtnRoute];
    [self.panelRouteBtn setAlternateImage:theme.imagePanelBtnRouteAlt];
    [self.panelRouteBtnSidebar setImage:theme.imagePanelBtnRoute];
    [self.panelRouteBtnSidebar setAlternateImage:theme.imagePanelBtnRouteAlt];
    
    //Video Buttons
    [self.panelVideoBtn setImage:theme.imagePanelBtnVideo];
    [self.panelVideoBtn setAlternateImage:theme.imagePanelBtnVideoAlt];
    [self.panelVideoBtnSidebar setImage:theme.imagePanelBtnVideo];
    [self.panelVideoBtnSidebar setAlternateImage:theme.imagePanelBtnVideoAlt];
    
    //Music Buttons
    [self.panelMusicBtn setImage:theme.imagePanelBtnMusic];
    [self.panelMusicBtn setAlternateImage:theme.imagePanelBtnMusicAlt];
    [self.panelMusicBtnSidebar setImage:theme.imagePanelBtnMusic];
    [self.panelMusicBtnSidebar setAlternateImage:theme.imagePanelBtnMusicAlt];
    
    //Clock Buttons
    [self.panelClockBtn setImage:theme.imagePanelBtnClock];
    [self.panelClockBtn setAlternateImage:theme.imagePanelBtnClockAlt];
    [self.panelClockBtnSidebar setImage:theme.imagePanelBtnClock];
    [self.panelClockBtnSidebar setAlternateImage:theme.imagePanelBtnClockAlt];
    
    //OSC Buttons
    [self.panelOSCBtn setImage:theme.imagePanelBtnOSC];
    [self.panelOSCBtn setAlternateImage:theme.imagePanelBtnOSCAlt];
    [self.panelOSCBtnSidebar setImage:theme.imagePanelBtnOSC];
    [self.panelOSCBtnSidebar setAlternateImage:theme.imagePanelBtnOSCAlt];
    
    //Settings Buttons
    [self.panelSettingsBtn setImage:theme.imagePanelBtnSettings];
    [self.panelSettingsBtn setAlternateImage:theme.imagePanelBtnSettingsAlt];
    [self.panelSettingsBtnSidebar setImage:theme.imagePanelBtnSettings];
    [self.panelSettingsBtnSidebar setAlternateImage:theme.imagePanelBtnSettingsAlt];
    
    //Terminal Buttons
    [self.panelTerminalBtn setImage:theme.imagePanelBtnTerminal];
    [self.panelTerminalBtn setAlternateImage:theme.imagePanelBtnTerminalAlt];
    [self.panelTerminalBtnSidebar setImage:theme.imagePanelBtnTerminal];
    [self.panelTerminalBtnSidebar setAlternateImage:theme.imagePanelBtnTerminalAlt];
    
    //Broadcast Buttons
    [self.panelBroadcastBtn setImage:theme.imagePanelBtnBroadcast];
    [self.panelBroadcastBtn setAlternateImage:theme.imagePanelBtnBroadcastAlt];
    [self.panelBroadcastBtnSidebar setImage:theme.imagePanelBtnBroadcast];
    [self.panelBroadcastBtnSidebar setAlternateImage:theme.imagePanelBtnBroadcastAlt];
}

- (void) changeTheme:(NSNotification *) notification {
    [self.view setNeedsDisplay:YES];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
