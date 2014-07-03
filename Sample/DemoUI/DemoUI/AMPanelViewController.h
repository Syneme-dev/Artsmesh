//
//  AMPanelViewController.h
//  DemoUI
//
//  Created by xujian on 3/6/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSUInteger, AMPanelViewType) {
    AMNetworkToolsPanelType = 1
};

@interface AMPanelViewController : NSViewController

- (IBAction)onTearClick:(id)sender;

@property(nonatomic) AMPanelViewType panelType;
@property (nonatomic) NSString* panelId;
@property (strong) IBOutlet NSView *toolBarView;
@property(nonatomic) NSString *title;
@property(nonatomic) NSViewController *subViewController;

@property (weak) IBOutlet NSTextField *titleView;
- (IBAction)closePanel:(id)sender;

@end
