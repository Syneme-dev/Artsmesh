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
    
    [self.panelHelpBtn setImage:theme.imagePanelBtnManual];
    [self.panelHelpBtn setAlternateImage:theme.imagePanelBtnManualAlt];
    [self.panelUserBtn setImage:theme.imagePanelBtnUser];
    [self.panelUserBtn setAlternateImage:theme.imagePanelBtnUserAlt];
    [self.panelGroupBtn setImage:theme.imagePanelBtnGroup];
    [self.panelGroupBtn setAlternateImage:theme.imagePanelBtnGroupAlt];
    [self.panelChatBtn setImage:theme.imagePanelBtnChat];
    [self.panelChatBtn setAlternateImage:theme.imagePanelBtnChatAlt];
    [self.panelSocialBtn setImage:theme.imagePanelBtnSocial];
    [self.panelSocialBtn setAlternateImage:theme.imagePanelBtnSocialAlt];
    [self.panelMapBtn setImage:theme.imagePanelBtnMap];
    [self.panelMapBtn setAlternateImage:theme.imagePanelBtnMapAlt];
    [self.panelRouteBtn setImage:theme.imagePanelBtnRoute];
    [self.panelRouteBtn setAlternateImage:theme.imagePanelBtnRouteAlt];
    [self.panelVideoBtn setImage:theme.imagePanelBtnVideo];
    [self.panelVideoBtn setAlternateImage:theme.imagePanelBtnVideoAlt];
    [self.panelMusicBtn setImage:theme.imagePanelBtnMusic];
    [self.panelMusicBtn setAlternateImage:theme.imagePanelBtnMusicAlt];
    [self.panelClockBtn setImage:theme.imagePanelBtnClock];
    [self.panelClockBtn setAlternateImage:theme.imagePanelBtnClockAlt];
    [self.panelOSCBtn setImage:theme.imagePanelBtnOSC];
    [self.panelOSCBtn setAlternateImage:theme.imagePanelBtnOSCAlt];
    [self.panelSettingsBtn setImage:theme.imagePanelBtnSettings];
    [self.panelSettingsBtn setAlternateImage:theme.imagePanelBtnSettingsAlt];
    [self.panelBroadcastBtn setImage:theme.imagePanelBtnBroadcast];
    [self.panelBroadcastBtn setImage:theme.imagePanelBtnBroadcastAlt];
}

@end
