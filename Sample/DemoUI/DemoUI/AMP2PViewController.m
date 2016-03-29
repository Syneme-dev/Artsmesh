//
//  AMP2PViewController.m
//  Artsmesh
//
//  Created by Whisky Zed on 163/24/.
//  Copyright © 2016年 Artsmesh. All rights reserved.
//

#import "AMP2PViewController.h"
//#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "AMVideoDeviceManager.h"

@interface AMP2PViewController ()
@property (weak) IBOutlet NSPopUpButtonCell *serverTitlePopUpButton;
@end

@implementation AMP2PViewController
{
    AVURLAsset* _currentAsset;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self updateServerTitle];
}

-(void)initAV{
    NSURL *url = nil;
    AVURLAsset *anAsset = [[AVURLAsset alloc] initWithURL:url options:nil];
}

-(void) updateServerTitle
{
    [_serverTitlePopUpButton removeAllItems];
    
    NSArray* serverTitles = [self getP2PServerNames];
    [_serverTitlePopUpButton addItemsWithTitles:serverTitles];

}

-(NSArray*)getP2PServerNames
{
    NSMutableArray*         serverNames   = [[NSMutableArray alloc] init];
    AMVideoDeviceManager*   deviceManager = [AMVideoDeviceManager sharedInstance];

    for (AMVideoDevice* device in [deviceManager allServerDevices]) {
        NSString* serverTitle = device.deviceID;
        [serverNames addObject:serverTitle];
    }
        
    return serverNames;
}


@end
