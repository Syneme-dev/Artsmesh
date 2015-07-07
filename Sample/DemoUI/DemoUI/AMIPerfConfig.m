//
//  AMIPerfConfig.m
//  Artsmesh
//
//  Created by whiskyzed on 7/3/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMIPerfConfig.h"
#import "UIFramework/AMFoundryFontView.h"
#import "UIFramework/AMCheckBoxView.h"
#import "UIFramework/AMRatioButtonView.h"
#import "UIFramework/AMPopUpView.h"

@interface AMIPerfConfig ()
@property (weak) IBOutlet AMPopUpView *roleSelector;
@property (weak) IBOutlet AMCheckBoxView *useUDP;
@property (weak) IBOutlet NSTextField *port;
@property (weak) IBOutlet NSTextField *bandwith;

@property (weak) IBOutlet AMCheckBoxView *tradeoff;

@property (weak) IBOutlet AMCheckBoxView *dualtest;
@end

@implementation AMIPerfConfig

- (void)windowDidLoad {
    [super windowDidLoad];
    
    self.useUDP.title = @"UDP";
    self.tradeoff.title = @"TRADEOFF";
    self.dualtest.title = @"DUAL TEST";
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}
- (IBAction)closeClicked:(id)sender {
    [self.window close];
}
- (IBAction)saveClicked:(id)sender {
    [self.window close];
}


@end
