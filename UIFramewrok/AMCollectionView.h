//
//  AMCollectionView.h
//  AMCollectionViewTest
//
//  Created by wangwei on 26/11/14.
//  Copyright (c) 2014 wangwei. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AMCollectionView : NSView

@property NSColor *backgroudColor;
@property NSUInteger itemGap;

-(void)addViewItem:(NSView *)view;
-(void)addViewItem:(NSView *)view atIndex:(NSUInteger)index;
-(void)addViewItems:(NSArray *)views;
-(void)removeViewItem:(NSView *)view;
-(void)removeViewAtIndex:(NSUInteger)index;
-(void)removeAllItems;

@end


