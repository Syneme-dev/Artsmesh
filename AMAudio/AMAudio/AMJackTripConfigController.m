//
//  AMJackTripConfigController.m
//  AMAudio
//
//  Created by Wei Wang on 9/5/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMJackTripConfigController.h"
#import "AMCoreData/AMCoreData.h"
#import "AMRouteViewController.h"
#import "AMJacktripConfigs.h"

@interface AMJackTripConfigController ()
@property (weak) IBOutlet NSPopUpButton *roleSelecter;
@property (weak) IBOutlet NSPopUpButton *peerSelecter;
@property (weak) IBOutlet NSPopUpButton *channelCountSelecter;
@property (weak) IBOutlet NSTextField *peerSelfDefine;
@property (weak) IBOutlet NSPopUpButton *portOffsetSelector;
@property (weak) IBOutlet NSTextField *qCount;
@property (weak) IBOutlet NSTextField *rCount;
@property (weak) IBOutlet NSTextField *bitRateRes;
@property (weak) IBOutlet NSButton *zerounderrunCheck;
@property (weak) IBOutlet NSButton *loopbackCheck;
@property (weak) IBOutlet NSButton *jamlinkCheck;
@property (weak) IBOutlet NSButton *createBtn;
@property (weak) IBOutlet NSTextField *showName;

@end

@implementation AMJackTripConfigController

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
    [self initControlStates];
    [self initParameters];
    [self initPortOffset];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self selector:@selector(jacktripChanged:)
     name:AM_RELOAD_JACK_CHANNEL_NOTIFICATION
     object:nil];
}

-(void)initControlStates
{
    [self.peerSelecter setEnabled:NO];
    [self.peerSelfDefine setEnabled:NO];
}

-(void)initPortOffset
{
    [self.portOffsetSelector removeAllItems];
    
    NSUInteger maxChannCount = [AMRouteView maxChannels];
    for (NSUInteger i = 0; i <maxChannCount; i++) {
        
        BOOL inUse = NO;
        for (AMJacktripInstance* jacktrip in self.jacktripManager.jackTripInstances) {
            if(jacktrip.portOffset == i){
                inUse = YES;
                break;
            }
        }
        
        if(!inUse){
            NSString* str = [NSString stringWithFormat:@"%lu", (unsigned long)i];
            [self.portOffsetSelector addItemWithTitle:str];
        }
    }
}

-(void)initParameters
{
    //init Jacktrip role
    [self.roleSelecter removeAllItems];
    [self.roleSelecter addItemWithTitle:@"Server"];
    [self.roleSelecter addItemWithTitle:@"Client"];
    
    //init show name
    self.showName.stringValue = [NSString stringWithFormat:@"Jacktrip_%lu", (unsigned long)[self.jacktripManager.jackTripInstances count]];
    
    //init peers
    [self.peerSelecter removeAllItems];
    NSArray* myGroupMem = [AMCoreData shareInstance].myLocalLiveGroup.users;
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    for (AMLiveUser* user in myGroupMem) {
        if([user.userid isNotEqualTo:mySelf.userid]){
            [self.peerSelecter addItemWithTitle:user.nickName];
            if ([self.peerSelfDefine.stringValue isEqualToString:@""]) {
                self.peerSelfDefine.stringValue = user.privateIp;
            }
        }
    }
    
    [self.peerSelecter addItemWithTitle:@"ip address"];
    
    //init channel count
    [self.channelCountSelecter removeAllItems];
    for (int i = 2; i <= 16; i *= 2) {
        NSString* numStr = [NSString stringWithFormat:@"%d", i];
        [self.channelCountSelecter addItemWithTitle:numStr];
    }
    
    //init port
    [self.portOffsetSelector selectItemAtIndex:0];
    
    //init -q
    self.qCount.stringValue = [NSString stringWithFormat:@"%d", 4];
   
    //init -r
    self.rCount.stringValue = [NSString stringWithFormat:@"%d", 1];
    
    //init -b
    self.bitRateRes.stringValue = [NSString stringWithFormat:@"%d", 16];
    
    //init -z
    [self.zerounderrunCheck setState:NSOffState];
    
    //init -I
    [self.loopbackCheck setState:NSOffState];
    
    //init -j
    [self.jamlinkCheck setState:NSOffState];
}

- (IBAction)roleSelectedChanged:(NSPopUpButton *)sender
{
    if ([sender.selectedItem.title isEqualToString:@"Client"]){
        [self.peerSelecter setEnabled:YES];
    }else{
        [self.peerSelecter setEnabled:NO];
        [self.peerSelfDefine setEnabled:NO];
    }
}

- (IBAction)peerSelectedChanged:(NSPopUpButton *)sender
{
    if ([sender.selectedItem.title isEqualToString:@"ip address"]) {
        [self.peerSelfDefine setEnabled:YES];
        self.peerSelfDefine.stringValue = @"";
    }else{
        [self.peerSelfDefine setEnabled:NO];
    
        NSArray* myGroupMem = [AMCoreData shareInstance].myLocalLiveGroup.users;
        for (AMLiveUser* user in myGroupMem) {
            if([user.nickName isEqualToString:sender.selectedItem.title]){
                self.peerSelfDefine.stringValue = user.privateIp;
            }
        }
    }
}

- (IBAction)startJacktrip:(NSButton *)sender
{
    AMJacktripConfigs* cfgs = [[AMJacktripConfigs alloc] init];
    
    cfgs.role = self.roleSelecter.selectedItem.title;
    cfgs.serverAddr = self.peerSelfDefine.stringValue;
    cfgs.portOffset = self.portOffsetSelector.selectedItem.title;
    cfgs.channelCount = self.channelCountSelecter.selectedItem.title;
    cfgs.qCount = self.qCount.stringValue;
    cfgs.rCount = self.rCount.stringValue;
    cfgs.bitrateRes = self.bitRateRes.stringValue;
    cfgs.zerounderrun = self.zerounderrunCheck.state == NSOnState;
    cfgs.loopback = self.loopbackCheck.state == NSOnState;
    cfgs.jamlink = self.jamlinkCheck.state == NSOnState;
    cfgs.clientName = self.showName.stringValue;
    
    if(![self.jacktripManager startJacktrip:cfgs]){
        //should tell user the error, will remove the exception later
        NSException* exp = [[NSException alloc]
                            initWithName:@"start jacktrip failed!"
                            reason:@"maybe port conflict"
                            userInfo:nil];
        [exp raise];
    }
}

-(void)jacktripChanged:(NSNotification*)notification
{
    [self initControlStates];
    [self initParameters];
    [self initPortOffset];
}


@end
