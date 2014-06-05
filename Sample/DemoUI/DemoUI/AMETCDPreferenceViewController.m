//
//  AMETCDPreferenceViewController.m
//  DemoUI
//
//  Created by 王 为 on 3/31/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMETCDPreferenceViewController.h"
#import "AMNetworkUtils/AMNetworkUtils.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import <UIFramework/AMButtonHandler.h>
#import "AMStatusNetModule/AMStatusNetModule.h"


#import "AMPopupMenuItem.h"



@interface AMETCDPreferenceViewController ()

@end

@implementation AMETCDPreferenceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Initialization code here.
    }
    return self;
}

-(void)awakeFromNib{
    [AMButtonHandler changeTabTextColor:self.etcdTabButton toColor:UI_Color_b7b7b7];
    
    [AMButtonHandler changeTabTextColor:self.generalTabButton toColor:UI_Color_b7b7b7];
    [AMButtonHandler changeTabTextColor:self.jackRouterTabButton toColor:UI_Color_b7b7b7];
    [AMButtonHandler changeTabTextColor:self.jackServerTabButton toColor:UI_Color_b7b7b7];
    [AMButtonHandler changeTabTextColor:self.audioTabButton toColor:UI_Color_b7b7b7];
    [AMButtonHandler changeTabTextColor:self.videoTabButton toColor:UI_Color_b7b7b7];
    [AMButtonHandler changeTabTextColor:self.statusnetTabButton toColor:UI_Color_b7b7b7];
    
    [AMButtonHandler changeTabTextColor:self.useIpv6Button toColor:UI_Color_b7b7b7];
    [AMButtonHandler changeTabTextColor:self.testStatusNetPost toColor:UI_Color_b7b7b7];
    
    [self resetPopupItems];
    [self.myPrivateIpPopup setPullsDown:YES];
    



}



- (IBAction)onETCDTabClick:(id)sender {
    [self.tabs selectTabViewItemWithIdentifier:@"1"];
}

- (IBAction)onJackServerTabClick:(id)sender {
    [self.tabs selectTabViewItemWithIdentifier:@"2"];
}

- (IBAction)privateIpSelected:(id)sender{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* myPrivateIP = [self.myPrivateIpPopup titleOfSelectedItem];
    [defaults setObject:myPrivateIP forKey:Preference_Key_General_PrivateIP];
}

- (IBAction)useIpv6Checked:(id)sender
{
    NSButton* checkbtn = sender;
    switch (checkbtn.state)
    {
        case 0:
            [self loadIpv4];
            break;
            
        default:
            [self loadIpv6];
            break;
    }
}

- (IBAction)statusNetTest:(id)sender {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* statusNetURL = [defaults stringForKey:Preference_Key_StatusNet_URL];
    NSString* username = [defaults stringForKey:Preference_Key_StatusNet_UserName];
    NSString* password = [defaults stringForKey:Preference_Key_StatusNet_Password];
    
    AMStatusNetModule* statusNetMod = [[AMStatusNetModule alloc] init];
    BOOL res = [statusNetMod postMessageToStatusNet:@"This is a test message send from Artsmesh through API"
                                   urlAddress:statusNetURL
                                 withUserName:username
                                 withPassword:password];
    
    if (res)
    {
        self.statusNetPostTestResult.stringValue = @"Post Succeeded!";
    }
    else
    {
        self.statusNetPostTestResult.stringValue = @"Post Failed!";
    }
    
}

- (IBAction)onGeneralClick:(id)sender {
      [self.tabs selectTabViewItemWithIdentifier:@"0"];
}

- (IBAction)onStatusNetClick:(id)sender {
     [self.tabs selectTabViewItemWithIdentifier:@"6"];
}

-(void)customPrefrence
{
    
    NSArray *itemArray = [self.myPrivateIpPopup itemArray];
    NSDictionary *attributes = [NSDictionary
                                dictionaryWithObjectsAndKeys:
                                [NSColor whiteColor], NSForegroundColorAttributeName,
                                [NSFont systemFontOfSize: [NSFont systemFontSize]],
                                NSFontAttributeName, nil];
    
     NSMenu *newMenu = [[NSMenu alloc] init];
    
    
    for (int i = 0; i < [itemArray count]; i++)
    {
        NSMenuItem *item = [itemArray objectAtIndex:i];
        NSAttributedString *as = [[NSAttributedString alloc]
                                  initWithString:[item title]
                                  attributes:attributes];
        [item setAttributedTitle:as];
        
        AMPopupMenuItem *popMenuItem=[[AMPopupMenuItem alloc]initWithTitle:item.title action:@selector(menuItem1Action:) keyEquivalent:@"" width:self.myPrivateIpPopup.frame.size.width];
        popMenuItem.popupButton=self.myPrivateIpPopup;
        [popMenuItem setEnabled:YES];
        [popMenuItem setTarget:self];
        [newMenu addItem:popMenuItem];
        
    }
   
    [self.myPrivateIpPopup setMenu:newMenu];
    

}

-(void)loadIpv4
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* oldIp = [defaults stringForKey:Preference_Key_General_PrivateIP];
    BOOL ipSelected = NO;
    int popupIndex = 0;
    
    [self.myPrivateIpPopup removeAllItems];
    NSArray* addresses = [NSHost currentHost].addresses;
    for (int i = 0; i < [addresses count]; i++)
    {
        NSString* ipStr = [addresses objectAtIndex:i];
        if ([AMNetworkUtils isValidIpv4:ipStr])
        {
            if ([ipStr hasPrefix:@"127"])
            {
                continue;
            }
            
            [self.myPrivateIpPopup addItemWithTitle:ipStr];
            if ([ipStr isEqualToString:oldIp])
            {
                [self.myPrivateIpPopup selectItemAtIndex:popupIndex];
                ipSelected = YES;
            }
            
            popupIndex++;
        }
    }
    
    if (!ipSelected && [[self.myPrivateIpPopup itemTitles] count] > 0)
    {
        [self.myPrivateIpPopup selectItemAtIndex:0];
        NSString* myPrivateIP = [[self.myPrivateIpPopup itemTitles] objectAtIndex:0];
        [defaults setObject:myPrivateIP forKey:Preference_Key_General_PrivateIP];
    }
    
    [self resetPopupItems];

}

-(void) loadIpv6
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* oldIp = [defaults stringForKey:Preference_Key_General_PrivateIP];
    BOOL ipSelected = NO;
    int popupIndex = 0;
    
    [self.myPrivateIpPopup removeAllItems];
    NSArray* addresses = [NSHost currentHost].addresses;
    for (int i = 0; i < [addresses count]; i++)
    {
        NSString* ipStr = [addresses objectAtIndex:i];
        if([AMNetworkUtils isValidIpv6:ipStr])
        {
            if ([ipStr hasPrefix:@"::"])
            {
                continue;
            }
            
            NSArray* ipStrComponents = [ipStr componentsSeparatedByString:@"%"];
            ipStr = [NSString stringWithFormat:@"[%@]", [ipStrComponents objectAtIndex:0]];
            
            [self.myPrivateIpPopup addItemWithTitle:ipStr];
            
            if ([ipStr isEqualToString:oldIp])
            {
                [self.myPrivateIpPopup selectItemAtIndex:popupIndex];
                ipSelected = YES;
            }
            popupIndex ++;
        }
    }
    
    if (!ipSelected && [[self.myPrivateIpPopup itemTitles] count] > 0)
    {
        [self.myPrivateIpPopup selectItemAtIndex:0];
        NSString* myPrivateIP = [[self.myPrivateIpPopup itemTitles] objectAtIndex:0];
        [defaults setObject:myPrivateIP forKey:Preference_Key_General_PrivateIP];
    }
    
    [self resetPopupItems];
}

-(void)resetPopupItems
{
    //self.myPrivateIpPopup
    
    NSArray *itemArray = [self.myPrivateIpPopup itemArray];
    int i;
    NSDictionary *attributes = [NSDictionary
                                dictionaryWithObjectsAndKeys:
                                [NSColor whiteColor], NSForegroundColorAttributeName,
                                [NSFont systemFontOfSize: [NSFont systemFontSize]],
                                NSFontAttributeName, nil];
    
    for (i = 0; i < [itemArray count]; i++) {
        NSMenuItem *item = [itemArray objectAtIndex:i];
        
        NSAttributedString *as = [[NSAttributedString alloc]
                                  initWithString:[item title]
                                  attributes:attributes];
        
        [item setAttributedTitle:as];
    }
}

-(void)loadSystemInfo
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    BOOL useIpv6 = [defaults boolForKey:Preference_Key_General_UseIpv6];
    
    NSString* machineName = [AMNetworkUtils getHostName];
    self.myMachineNameField.stringValue = machineName;
    [defaults setObject:machineName forKey:Preference_Key_General_MachineName];
    
    if (useIpv6)
    {
        [self loadIpv6];
    }
    else
    {
        [self loadIpv4];
    }
}

@end
