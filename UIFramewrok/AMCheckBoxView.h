//
//  AMCheckBoxView.h
//  CheckBoxTest
//
//  Created by Wei Wang on 7/14/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMTheme.h"

#define AM_CHECKBOX_CHANGED @"AM_CHECKBOX_CHANGED"

@protocol AMCheckBoxDelegeate;

@interface AMCheckBoxView : NSControl

@property NSString* title;
//@property BOOL  checked;
@property NSFont* font;
@property NSColor* textColor;
@property NSColor* backgroupColor;
@property NSColor* btnBackGroundColor;
@property NSColor* btnColor;
@property BOOL readOnly;
@property BOOL drawBackground;

@property (strong) AMTheme *curTheme;
@property (strong) NSColor *curTextColor;

@property (weak) IBOutlet id<AMCheckBoxDelegeate>delegate;

-(void)setFontSize:(float)newSize;
-(void)setChecked:(BOOL)checked;
-(BOOL)checked;

@end


@protocol AMCheckBoxDelegeate <NSObject>

-(void)onChecked:(AMCheckBoxView*)sender;

@end
