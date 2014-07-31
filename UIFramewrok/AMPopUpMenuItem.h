//
//  AMPopUpMenuItemView.h
//  MyPopUpTest
//
//  Created by 王 为 on 7/31/14.
//  Copyright (c) 2014 王 为. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@protocol AMPopUpMenuItemDelegeate;

@interface AMPopUpMenuItem : NSView

@property NSString* title;
@property NSFont* font;
@property NSColor* textColor;
@property NSColor* backgroupColor;
@property NSColor* mouseOverColor;

@property id<AMPopUpMenuItemDelegeate> delegate;

@end



@protocol AMPopUpMenuItemDelegeate <NSObject>

-(void)itemSelected:(AMPopUpMenuItem*)sender;

@end