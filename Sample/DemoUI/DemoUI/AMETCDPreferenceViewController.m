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
#import <UIFramework/AMCheckBoxView.h>
#import <AMCommonTools/AMCommonTools.h>
#import <AMStatusNet/AMStatusNet.h>


#import "AMPopupMenuItem.h"



@interface AMETCDPreferenceViewController ()<AMCheckBoxDelegeate>
@property (weak) IBOutlet AMCheckBoxView *Ipv6checkBox;

@end

@implementation AMETCDPreferenceViewController
{
    dispatch_queue_t _preference_queue;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Initialization code here.
    }
    return self;
}

-(void)awakeFromNib{
    [AMButtonHandler changeTabTextColor:self.generalTabButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.jackRouterTabButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.jackServerTabButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.audioTabButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.videoTabButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.statusnetTabButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.testStatusNetPost toColor:UI_Color_blue];
    
    _preference_queue = dispatch_queue_create("preference_queue", DISPATCH_QUEUE_SERIAL);
    
    [self resetPopupItems];
    [self.myPrivateIpPopup setPullsDown:YES];
    
    self.Ipv6checkBox.readOnly= NO;
    self.Ipv6checkBox.title = @"USE IPV6";
    self.Ipv6checkBox.delegate = self;

}

- (IBAction)onJackServerTabClick:(id)sender {
    [self.tabs selectTabViewItemWithIdentifier:@"2"];
}

- (IBAction)privateIpSelected:(id)sender{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* myPrivateIP = [self.myPrivateIpPopup titleOfSelectedItem];
    [defaults setObject:myPrivateIP forKey:Preference_Key_User_PrivateIp];
    
    [self.myPrivateIpPopup selectItem:self.myPrivateIpPopup.selectedItem];
}

- (IBAction)statusNetTest:(id)sender {
    BOOL res = [[AMStatusNet shareInstance] postMessageToStatusNet:@"This is a test message send from Artsmesh through API"];
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
        
        AMPopupMenuItem *popMenuItem=[[AMPopupMenuItem alloc]initWithTitle:item.title  keyEquivalent:@"" width:self.myPrivateIpPopup.frame.size.width];
        popMenuItem.popupButton=self.myPrivateIpPopup;
        [popMenuItem setEnabled:YES];
        [popMenuItem setTarget:self];
        [newMenu addItem:popMenuItem];
        
    }
   
    [self.myPrivateIpPopup setMenu:newMenu];
}

-(void)loadIpv4
{
    dispatch_async(_preference_queue, ^{
        NSArray* addresses = [NSHost currentHost].addresses;
        NSMutableArray* ipv4s = [[NSMutableArray alloc]init];
        for (int i = 0; i < [addresses count]; i++)
        {
            NSString* ipStr = [addresses objectAtIndex:i];
            if ([AMCommonTools isValidIpv4:ipStr])
            {
//                if ([ipStr hasPrefix:@"127"])
//                {
//                    continue;
//                }
                
                [ipv4s addObject:ipStr];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            NSString* oldIp = [defaults stringForKey:Preference_Key_User_PrivateIp];
            BOOL ipSelected = NO;
            int popupIndex = 0;
            
            [self.myPrivateIpPopup removeAllItems];
            
            for (NSString* ipStr in ipv4s) {
                [self.myPrivateIpPopup addItemWithTitle:ipStr];
                if ([ipStr isEqualToString:oldIp])
                {
                    [self.myPrivateIpPopup selectItemAtIndex:popupIndex];
                    ipSelected = YES;
                }
                
                 popupIndex++;
            }
            
            if (!ipSelected && [[self.myPrivateIpPopup itemTitles] count] > 0)
            {
                [self.myPrivateIpPopup selectItemAtIndex:0];
                NSString* myPrivateIP = [[self.myPrivateIpPopup itemTitles] objectAtIndex:0];
                [defaults setObject:myPrivateIP forKey:Preference_Key_User_PrivateIp];
            }
            
            [self resetPopupItems];
        });
    
    });
}

-(void) loadIpv6
{
    dispatch_async(_preference_queue, ^{
        NSArray* addresses = [NSHost currentHost].addresses;
        NSMutableArray* ipv6s = [[NSMutableArray alloc]init];
        for (int i = 0; i < [addresses count]; i++)
        {
            NSString* ipStr = [addresses objectAtIndex:i];
            if ([AMCommonTools isValidIpv6:ipStr])
            {
//                if ([ipStr hasPrefix:@"::"])
//                {
//                    continue;
//                }
                
                NSArray* ipStrComponents = [ipStr componentsSeparatedByString:@"%"];
                ipStr = [NSString stringWithFormat:@"[%@]", [ipStrComponents objectAtIndex:0]];
                
                [ipv6s addObject:ipStr];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            NSString* oldIp = [defaults stringForKey:Preference_Key_User_PrivateIp];
            BOOL ipSelected = NO;
            int popupIndex = 0;
            
            [self.myPrivateIpPopup removeAllItems];
            
            for (NSString* ipStr in ipv6s) {
                [self.myPrivateIpPopup addItemWithTitle:ipStr];
                if ([ipStr isEqualToString:oldIp])
                {
                    [self.myPrivateIpPopup selectItemAtIndex:popupIndex];
                    ipSelected = YES;
                }
                
                popupIndex++;
            }
            
            if (!ipSelected && [[self.myPrivateIpPopup itemTitles] count] > 0)
            {
                [self.myPrivateIpPopup selectItemAtIndex:0];
                NSString* myPrivateIP = [[self.myPrivateIpPopup itemTitles] objectAtIndex:0];
                [defaults setObject:myPrivateIP forKey:Preference_Key_User_PrivateIp];
            }
            
            [self resetPopupItems];
        });
        
    });
}


-(void)loadMachineName
{
    dispatch_async(_preference_queue, ^{
        NSHost* host = [NSHost currentHost];
        NSString* machineName = host.name;
        
        self.myMachineNameField.stringValue = machineName;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:machineName forKey:Preference_Key_General_MachineName];
        });
    });
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
    [self loadMachineName];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    BOOL useIpv6 = [defaults boolForKey:Preference_Key_General_UseIpv6];
    
    if (useIpv6)
    {
        self.Ipv6checkBox.checked = YES;
        [self loadIpv6];
    }
    else
    {
        self.Ipv6checkBox.checked = NO;
        [self loadIpv4];
    }
}

-(void)onChecked:(AMCheckBoxView *)sender
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:sender.checked forKey:Preference_Key_General_UseIpv6];
    
    if(sender.checked){
          [self loadIpv6];
    }else{
        [self loadIpv4];
    }
}

@end
