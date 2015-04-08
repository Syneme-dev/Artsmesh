//
//  AMMusicScoreViewController.h
//  DemoUI
//
//  Created by xujian on 6/26/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>



@interface AMScoreViewController : NSViewController
@property (weak) IBOutlet NSButton *loadScoreBtn;
@property (weak) IBOutlet NSButton *removeScoreBtn;

- (IBAction) addMusicScoreItem:(id)sender;

@end