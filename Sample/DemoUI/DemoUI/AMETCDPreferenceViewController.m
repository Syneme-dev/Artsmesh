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

- (IBAction)onETCDTabClick:(id)sender {
    [self.tabs selectTabViewItemAtIndex:0];
}

- (IBAction)onJackServerTabClick:(id)sender {
    [self.tabs selectTabViewItemAtIndex:1];
}

- (IBAction)privateIpSelected:(id)sender {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* myPrivateIP = [self.myPrivateIpPopup titleOfSelectedItem];
    [defaults setObject:myPrivateIP forKey:Preference_Key_PrivateIP];
}

-(void)loadSystemInfo
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    NSString* machineName = [AMNetworkUtils getHostName];
    self.myMachineNameField.stringValue = machineName;
    [defaults setObject:machineName forKey:Preference_Key_MachineName];
    
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
            
            [defaults setObject:ipStr forKey:Preference_Key_PrivateIP];
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
