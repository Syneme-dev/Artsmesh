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
    
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"backgroundColor"] isEqualToString:@"White"])
       {
        //self.color=[NSColor colorWithCalibratedRed:0.863 green:0.867 blue:0.871 alpha:1];
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
