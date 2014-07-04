//
//  AMMainWindowController.h
//  DemoUI
//
//  Created by xujian on 4/17/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class AMFoundryFontView;

@interface AMMainWindowController : NSWindowController<NSWindowDelegate>
@property (weak) IBOutlet NSButton *meshBtn;

- (IBAction)mesh:(id)sender;
- (void)showDefaultWindow ;
@property NSMutableDictionary *panelControllers;
@property (weak) IBOutlet NSTextField *versionLabel;
- (IBAction)onSidebarItemClick:(NSButton *)sender;
@property (weak) IBOutlet AMFoundryFontView *amTimer;

-(void)setSideBarItemStatus:(NSString *) identifier withStatus:(Boolean)status;

- (IBAction)onTimerControlItemClick:(NSButton *)sender;
- (IBAction)copyPanel:(id)sender;

@end
