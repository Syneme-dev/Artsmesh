//
//  AMGroupPreviewPanelController.h
//  DemoUI
//
//  Created by Brad Phillips on 11/6/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UIFramework/AMFoundryFontView.h"
#import "AMCoreData/AMCoreData.h"

@interface AMGroupPreviewPanelController : NSViewController

@property (strong) IBOutlet NSClipView *descScrollView;
@property (strong) IBOutlet NSClipView *descClipView;
@property (strong) IBOutlet NSTextView *descTextView;

@property AMLiveGroup *group;
@property NSMutableAttributedString *groupDesc;

@end
