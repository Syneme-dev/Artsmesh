//
//  AMGroupOutlineLabelCellController.h
//  DemoUI
//
//  Created by 王 为 on 6/30/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AMGroupOutlineLabelCellController : NSViewController

@property NSString* labelText;
@property NSMutableArray* groupControllers;

-(void)updateUI;

@end
