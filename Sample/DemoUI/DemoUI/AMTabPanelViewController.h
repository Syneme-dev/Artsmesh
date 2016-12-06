//
//  AMTabPanelViewController.h
//  DemoUI
//
//  Created by xujian on 7/9/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "UIFramework/AMTheme.h"

@interface AMTabPanelViewController : NSViewController


@property (strong) IBOutlet NSMutableArray *tabButtons;
@property  NSInteger showingTabsCount;
-(void)registerTabButtons;
@property (strong) IBOutlet NSTabView *tabs;
-(void)selectTabIndex:(NSInteger)index;
@property(nonatomic) NSButton *currentPushedDownButton;

@property (strong) AMTheme *curTheme;
@property (strong) NSColor *textColor;
@property (strong) NSColor *textColorSelected;

- (void)pushDownButton:(NSButton *)button;
- (void)changeTheme:(NSNotification *)notification;

@end
