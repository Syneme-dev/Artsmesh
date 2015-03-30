//
//  AMScoreCollectionView.h
//  Artsmesh
//
//  Created by whiskyzed on 3/23/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AMScoreCollectionView : NSView

@property NSColor *backgroudColor;
@property NSUInteger itemGap;
@property NSUInteger selectable;
@property BOOL       nowBar;

@property NSUInteger        mode;
@property  NSTimeInterval   timeInterval;
@property    CGFloat         scrollDelta;

-(void) removeSelectedItem;
-(void)addViewItem:(NSView *)view;
-(void)addViewItem:(NSView *)view atIndex:(NSUInteger)index;
-(void)addViewItems:(NSArray *)views;
-(void)removeViewItem:(NSView *)view;
-(void)removeViewAtIndex:(NSUInteger)index;
-(void)removeAllItems;

@end
