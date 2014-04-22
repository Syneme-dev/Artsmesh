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
    [self changeTabTextColor:self.etcdTabButton];
    [self changeTabTextColor:self.generalTabButton];
    [self changeTabTextColor:self.jackServerTabButton];
    
    
    [self changeTabTextColor:self.jackRouterTabButton];
    [self changeTabTextColor:self.audioTabButton];
    [self changeTabTextColor:self.videoTabButton];
    [self changeTabTextColor:self.statusnetTabButton];
}

-(void)changeTabTextColor:(NSButton*) button{
    //#b7b7b7
    NSColor *color =
    [NSColor colorWithCalibratedRed:(168)/255.0f green:(168)/255.0f blue:(168)/255.0f alpha:1.0f];
    NSMutableAttributedString *colorTitle =
    [[NSMutableAttributedString alloc] initWithAttributedString:[button attributedTitle]];
    NSRange titleRange = NSMakeRange(0, [colorTitle length]);
    
    [colorTitle addAttribute:NSForegroundColorAttributeName
                       value:color
                       range:titleRange];
    
    [button setAttributedTitle:colorTitle];
}

- (IBAction)onETCDTabClick:(id)sender {
    [self.tabs selectTabViewItemAtIndex:1];
}

- (IBAction)onJackServerTabClick:(id)sender {
    [self.tabs selectTabViewItemAtIndex:2];
}

- (IBAction)privateIpSelected:(id)sender {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* myPrivateIP = [self.myPrivateIpPopup titleOfSelectedItem];
    [defaults setObject:myPrivateIP forKey:Preference_Key_General_PrivateIP];
}

- (IBAction)onGeneralClick:(id)sender {
      [self.tabs selectTabViewItemAtIndex:0];
}

-(void)customPrefrence
{
    
    NSArray *itemArray = [self.myPrivateIpPopup itemArray];
    NSDictionary *attributes = [NSDictionary
                                dictionaryWithObjectsAndKeys:
                                [NSColor whiteColor], NSForegroundColorAttributeName,
                                [NSFont systemFontOfSize: [NSFont systemFontSize]],
                                NSFontAttributeName, nil];
    
    for (int i = 0; i < [itemArray count]; i++)
    {
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
    
    NSString* machineName = [AMNetworkUtils getHostName];
    self.myMachineNameField.stringValue = machineName;
    [defaults setObject:machineName forKey:Preference_Key_General_MachineName];
    
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
            [self.myPrivateIpPopup selectItemAtIndex:i];
            
            [defaults setObject:ipStr forKey:Preference_Key_General_PrivateIP];
        }
        
        else if([AMNetworkUtils isValidIpv6:ipStr])
        {
            if ([ipStr hasPrefix:@"::"])
            {
                continue;
            }
            
            [self.myPrivateIpPopup addItemWithTitle:ipStr];
        }
    }
}

@end
