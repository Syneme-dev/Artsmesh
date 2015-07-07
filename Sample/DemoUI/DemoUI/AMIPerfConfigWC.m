//
//  AMIPerfConfig.m
//  Artsmesh
//
//  Created by whiskyzed on 7/3/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMIPerfConfigWC.h"
#import "UIFramework/AMFoundryFontView.h"
#import "UIFramework/AMCheckBoxView.h"
#import "UIFramework/AMRatioButtonView.h"
#import "UIFramework/AMPopUpView.h"
#import "UIFramework/AMButtonHandler.h"
#import "UIFramework/AMBlueBorderButton.h"

@interface AMIPerfConfigWC ()<AMPopUpViewDelegeate>

@property (weak) IBOutlet AMBlueBorderButton *cancelButton;
@property (weak) IBOutlet AMBlueBorderButton *saveButton;

@property (weak) IBOutlet AMPopUpView *roleSelector;
@property (weak) IBOutlet AMCheckBoxView *useUDP;
@property (weak) IBOutlet NSTextField *port;
@property (weak) IBOutlet NSTextField *bandwith;
@property (weak) IBOutlet AMCheckBoxView *tradeoff;
@property (weak) IBOutlet AMCheckBoxView *dualtest;
@end

@implementation AMIPerfConfig

@end


@implementation AMIPerfConfigWC

- (void)windowDidLoad {
    [super windowDidLoad];
    
    _iperfConfig = [[AMIPerfConfig alloc] init];
    [self setupUI];
   
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)peerSelectedChanged:(AMPopUpView*)sender
{
    if (sender == self.roleSelector) {
        BOOL clientEnable = [self.roleSelector.stringValue isEqualToString:@"CLIENT"];
        [self.tradeoff setEnabled:clientEnable];
        [self.dualtest setEnabled:clientEnable];
    }
}



- (void) setupUI
{
    [AMButtonHandler changeTabTextColor:self.saveButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.cancelButton toColor:UI_Color_blue];
    [self.saveButton.layer      setBorderWidth:1.0];
    [self.saveButton.layer      setBorderColor:UI_Color_blue.CGColor];
    [self.cancelButton.layer    setBorderWidth:1.0];
    [self.cancelButton.layer    setBorderColor:UI_Color_blue.CGColor];
    
    
    [self.roleSelector addItemWithTitle:@"SERVER"];
    [self.roleSelector addItemWithTitle:@"CLIENT"];
   
    self.useUDP.title = @"UDP";
    self.tradeoff.title = @"TRADEOFF";
    self.dualtest.title = @"DUAL TEST";

}

- (IBAction)closeClicked:(id)sender {
    [self.window close];
}

- (void) updateIPerfConfig
{
    _iperfConfig.serverRole = [self.roleSelector.stringValue isEqualTo:@"SERVER"];
    _iperfConfig.useUDP =[self.useUDP checked];
    
    if ([self.port integerValue] > 0) {
        _iperfConfig.port = [self.port integerValue];
    }
    
    if ([self.bandwith integerValue] > 0) {
        _iperfConfig.bandwith = [self.bandwith integerValue];
    }
    
    if ([self.roleSelector.stringValue isEqualTo:@"SERVER"]) {
        _iperfConfig.tradeoff = NO;
        _iperfConfig.dualtest = NO;
    }else{
        _iperfConfig.tradeoff = [self.tradeoff checked];
        _iperfConfig.dualtest = [self.dualtest checked];
    }
}

- (IBAction)saveClicked:(id)sender {
    [self updateIPerfConfig];
    
    [self.window close];
}


@end
