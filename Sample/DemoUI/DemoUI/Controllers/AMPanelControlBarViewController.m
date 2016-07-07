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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setWhiteThemeIcons:) name:@"WhiteTheme" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setBlackThemeIcons:) name:@"BlackTheme" object:nil];
    
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundColor"] isEqualToString:@"White"])
    {
        //self.color=[NSColor colorWithCalibratedRed:0.863 green:0.867 blue:0.871 alpha:1];
        [self setWhiteThemeIcons];
    }
    
    
}

-(void)setBlackThemeIcons:(NSNotification *)notification{
    [self setBlackThemeIcons];
}

-(void)setWhiteThemeIcons:(NSNotification *)notification{
    [self setWhiteThemeIcons];
}

-(void)setBlackThemeIcons{
    NSImage *greyUser=[NSImage imageNamed:@"SideBar_user_h"];
    NSImage *blackUser=[NSImage imageNamed:@"SideBar_user"];
    
    NSImage *greyGroup=[NSImage imageNamed:@"SideBar_group_h"];
    NSImage *blackGroup=[NSImage imageNamed:@"SideBar_group"];
    
    NSImage *greyChat=[NSImage imageNamed:@"SideBar_chat_h"];
    NSImage *blackChat=[NSImage imageNamed:@"SideBar_chat"];
    
    NSImage *greySocial=[NSImage imageNamed:@"SideBar_social_h"];
    NSImage *blackSocial=[NSImage imageNamed:@"SideBar_social"];
    
    NSImage *greyMap=[NSImage imageNamed:@"SideBar_mapView_h"];
    NSImage *blackMap=[NSImage imageNamed:@"SideBar_mapView"];
    
    NSImage *greyLink=[NSImage imageNamed:@"SideBar_route_h"];
    NSImage *blackLink=[NSImage imageNamed:@"SideBar_route"];
    
    NSImage *greyMix=[NSImage imageNamed:@"SideBar_video_h"];
    NSImage *blackMix=[NSImage imageNamed:@"SideBar_video"];
    
    NSImage *greyMusic=[NSImage imageNamed:@"SideBar_musicScore_h"];
    NSImage *blackMusic=[NSImage imageNamed:@"SideBar_musicScore"];
    
    
    NSImage *greyClock=[NSImage imageNamed:@"SideBar_clock_h"];
    NSImage *blackClock=[NSImage imageNamed:@"SideBar_clock"];
    
    NSImage *greyOsc=[NSImage imageNamed:@"SideBar_osc_h"];
    NSImage *blackOsc=[NSImage imageNamed:@"SideBar_osc"];
    
    NSImage *greyTerminal=[NSImage imageNamed:@"SideBar_terminal_h"];
    NSImage *blackTerminal=[NSImage imageNamed:@"SideBar_terminal"];
    
    NSImage *greySetting=[NSImage imageNamed:@"SideBar_setting_h"];
    NSImage *blackSetting=[NSImage imageNamed:@"SideBar_setting"];
    
    NSImage *greyRadio=[NSImage imageNamed:@"menu_broadcast_icon_h"];
    NSImage *blackRadio=[NSImage imageNamed:@"menu_broadcast_icon"];
    
    NSImage *greyQuestion=[NSImage imageNamed:@"SideBar_Manual_h"];
    NSImage *blackQuestion=[NSImage imageNamed:@"SideBar_Manual"];
    
    [self.userBtn setImage:blackUser];
    [self.userBtn setAlternateImage:greyUser];
    [self.groupBtn setImage:blackGroup];
    [self.groupBtn setAlternateImage:greyGroup];
    [self.chatBtn setImage:blackChat];
    [self.chatBtn setAlternateImage:greyChat];
    [self.socialBtn setImage:blackSocial];
    [self.socialBtn setAlternateImage:greySocial];
    [self.mapBtn setImage:blackMap];
    [self.mapBtn setAlternateImage:greyMap];
    
    [self.visualBtn setImage:blackLink];
    [self.visualBtn setAlternateImage:greyLink];
    [self.mixingBtn setImage:blackMix];
    [self.mixingBtn setAlternateImage:greyMix];
    [self.musicScoreBtn setImage:blackMusic];
    [self.musicScoreBtn setAlternateImage:greyMusic];
    [self.clockBtn setImage:blackClock];
    [self.clockBtn setAlternateImage:greyClock];
    [self.oscBtn setImage:blackOsc];
    [self.oscBtn setAlternateImage:greyOsc];
    [self.terminalBtn setImage:blackTerminal];
    [self.terminalBtn setAlternateImage:greyTerminal];
    [self.settingBtn setImage:blackSetting];
    [self.settingBtn setAlternateImage:greySetting];
    [self.radioBtn setImage:blackRadio];
    [self.radioBtn setAlternateImage:greyRadio];
    [self.questionBtn setImage:blackQuestion];
    [self.questionBtn setAlternateImage:greyQuestion];
    
}


-(void)setWhiteThemeIcons{
    NSImage *whiteUser=[NSImage imageNamed:@"controlbar_WhiteUser"];
    NSImage *redUser=[NSImage imageNamed:@"controlbar_RedUser"];
    
    NSImage *whiteGroup=[NSImage imageNamed:@"controlbar_WhiteGroup"];
    NSImage *redGroup=[NSImage imageNamed:@"controlbar_RedGroup"];
    
    NSImage *whiteChat=[NSImage imageNamed:@"controlbar_WhiteChat"];
    NSImage *redChat=[NSImage imageNamed:@"controlbar_RedChat"];
    
    NSImage *whiteSocial=[NSImage imageNamed:@"controlbar_WhiteSocial"];
    NSImage *redSocial=[NSImage imageNamed:@"controlbar_RedSocial"];
    
    NSImage *whiteMap=[NSImage imageNamed:@"controlbar_WhiteMap"];
    NSImage *redMap=[NSImage imageNamed:@"controlbar_RedMap"];
    
    NSImage *whiteLink=[NSImage imageNamed:@"controlbar_WhiteLink"];
    NSImage *redLink=[NSImage imageNamed:@"controlbar_RedLink"];
    
    NSImage *whiteMix=[NSImage imageNamed:@"controlbar_WhiteMix"];
    NSImage *redMix=[NSImage imageNamed:@"controlbar_RedMix"];
    
    NSImage *whiteMusic=[NSImage imageNamed:@"controlbar_WhiteMusic"];
    NSImage *redMusic=[NSImage imageNamed:@"controlbar_RedMusic"];
    
    
    NSImage *whiteClock=[NSImage imageNamed:@"controlbar_WhiteClock"];
    NSImage *redClock=[NSImage imageNamed:@"controlbar_RedClock"];
    
    NSImage *whiteOsc=[NSImage imageNamed:@"controlbar_WhiteOsc"];
    NSImage *redOsc=[NSImage imageNamed:@"controlbar_RedOsc"];
    
    NSImage *whiteTerminal=[NSImage imageNamed:@"controlbar_WhiteTerminal"];
    NSImage *redTerminal=[NSImage imageNamed:@"controlbar_RedTerminal"];
    
    NSImage *whiteSetting=[NSImage imageNamed:@"controlbar_WhiteSetting"];
    NSImage *redSetting=[NSImage imageNamed:@"controlbar_RedSetting"];
    
    NSImage *whiteRadio=[NSImage imageNamed:@"controlbar_WhiteRadio"];
    NSImage *redRadio=[NSImage imageNamed:@"controlbar_RedRadio"];
    
    NSImage *whiteQuestion=[NSImage imageNamed:@"controlbar_WhiteQuestion"];
    NSImage *redQuestion=[NSImage imageNamed:@"controlbar_RedQuestion"];
    
    [self.userBtn setImage:whiteUser];
    [self.userBtn setAlternateImage:redUser];
    [self.groupBtn setImage:whiteGroup];
    [self.groupBtn setAlternateImage:redGroup];
    [self.chatBtn setImage:whiteChat];
    [self.chatBtn setAlternateImage:redChat];
    [self.socialBtn setImage:whiteSocial];
    [self.socialBtn setAlternateImage:redSocial];
    [self.mapBtn setImage:whiteMap];
    [self.mapBtn setAlternateImage:redMap];
    [self.visualBtn setImage:whiteLink];
    [self.visualBtn setAlternateImage:redLink];
    [self.mixingBtn setImage:whiteMix];
    [self.mixingBtn setAlternateImage:redMix];
    [self.musicScoreBtn setImage:whiteMusic];
    [self.musicScoreBtn setAlternateImage:redMusic];
    [self.clockBtn setImage:whiteClock];
    [self.clockBtn setAlternateImage:redClock];
    [self.oscBtn setImage:whiteOsc];
    [self.oscBtn setAlternateImage:redOsc];
    [self.terminalBtn setImage:whiteTerminal];
    [self.terminalBtn setAlternateImage:redTerminal];
    [self.settingBtn setImage:whiteSetting];
    [self.settingBtn setAlternateImage:redSetting];
    [self.radioBtn setImage:whiteRadio];
    [self.radioBtn setAlternateImage:redRadio];
    [self.questionBtn setImage:whiteQuestion];
    [self.questionBtn setAlternateImage:redQuestion];
    
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

@end
