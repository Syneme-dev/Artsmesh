//  AMRatioButtonView.h
//  UIFramework
//  Created by whiskyzed on 12/28/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.

#import <Cocoa/Cocoa.h>

@protocol AMRatioButtonDelegeate;

@interface AMRatioButtonView : NSControl

@property NSString* title;
@property NSFont* font;
@property NSColor* textColor;
@property NSColor* backgroupColor;
@property NSColor* btnBackGroundColor;
@property NSColor* btnColor;
@property BOOL readOnly;
@property BOOL drawBackground;

@property id<AMRatioButtonDelegeate>delegate;

-(void)setChecked:(BOOL)checked;
-(BOOL)checked;

@end


@protocol AMRatioButtonDelegeate <NSObject>
-(void)onChecked:(AMRatioButtonView*)sender;
@end