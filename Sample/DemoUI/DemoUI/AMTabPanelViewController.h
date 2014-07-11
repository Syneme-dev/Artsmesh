//
//  AMTabPanelViewController.h
//  DemoUI
//
//  Created by xujian on 7/9/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//


@interface AMTabPanelViewController : NSViewController


@property (strong) IBOutlet NSMutableArray *tabButtons;
@property  NSInteger showingTabsCount;
-(void)registerTabButtons;
@property (strong) IBOutlet NSTabView *tabs;
-(void)selectTabIndex:(NSInteger)index;

@end
