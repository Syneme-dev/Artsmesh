//
//  AMLiveMapProgramViewController.h
//  DemoUI
//
//  Created by Brad Phillips on 10/28/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMCoreData/AMCoreData.h"
#import "UIFramework/AMFoundryFontTextView.h"

@interface AMLiveMapProgramViewController : NSViewController

@property (strong) IBOutlet NSScrollView *descScrollView;

@property (strong) IBOutlet AMFoundryFontTextView *scrollTextView;

@property AMLiveGroup *group;
@property NSMutableAttributedString *desc;

@end
