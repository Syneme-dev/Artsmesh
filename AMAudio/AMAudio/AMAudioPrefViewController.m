//
//  AMAudioPrefViewController.m
//  AMAudio
//
//  Created by 王 为 on 8/22/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMAudioPrefViewController.h"
#import "AMAudioDeviceManager.h"

@interface AMAudioPrefViewController ()
@property (weak) IBOutlet NSPopUpButton *driverBox;
@property (weak) IBOutlet NSPopUpButton *inputDevBox;
@property (weak) IBOutlet NSPopUpButton *outputDevBox;
@property (weak) IBOutlet NSPopUpButton *sampleRateBox;
@property (weak) IBOutlet NSPopUpButton *bufferSizeBox;
@property (weak) IBOutlet NSButton *hogModeCheck;
@property (weak) IBOutlet NSButton *compensationCheck;
@property (weak) IBOutlet NSButton *portMornitingCheck;
@property (weak) IBOutlet NSButton *midiCheck;
@property (weak) IBOutlet NSPopUpButton *interfaceInChansBox;
@property (weak) IBOutlet NSPopUpButton *interfaceOutChansBox;

@end

@implementation AMAudioPrefViewController
{
    AMAudioDeviceManager* _devManager;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        _devManager = [[AMAudioDeviceManager alloc] init];
        
        [self fillDriverBox];
    }
    return self;
}

-(void)fillDriverBox
{
    [self.driverBox removeAllItems];
    [self.driverBox addItemsWithTitles:@[@"coreaudio"]];
}

@end
