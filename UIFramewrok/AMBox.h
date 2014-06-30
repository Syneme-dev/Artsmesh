//
//  AMBox.h
//
//  Created by lattesir on 5/20/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMBoxItem.h"

typedef NS_ENUM(NSUInteger, AMBoxStyle) {
    AMBoxHorizontal,
    AMBoxVertical
};

@interface AMBox : AMBoxItem<NSDraggingDestination>

@property(nonatomic, readonly) AMBoxItem *firstVisibleItem;
@property(nonatomic, readonly) AMBoxItem *lastVisibleItem;
@property(nonatomic, readonly) AMBoxStyle style;
@property(nonatomic) CGFloat paddingLeft;
@property(nonatomic) CGFloat paddingRight;
@property(nonatomic) CGFloat paddingTop;
@property(nonatomic) CGFloat paddingBottom;
@property(nonatomic) CGFloat gapBetweenItems;
@property(nonatomic) BOOL allowBecomeEmpty;
@property(nonatomic, copy) AMBoxItem *(^prepareForAdding)(AMBoxItem *);

+ (AMBox *)hbox;
+ (AMBox *)vbox;

// designated initializer
- (instancetype)initWithFrame:(NSRect)frameRect sytle:(AMBoxStyle)style;
- (void)setPadding:(CGFloat)padding;
- (void)doBoxLayout;
- (BOOL)dropBoxItem:(AMBoxItem *)boxItem atLocation:(NSPoint)point;
- (void)didRemoveBoxItem:(AMBoxItem *)boxItem;
- (AMBoxItem *)boxItemBelowPoint:(NSPoint)point;
- (CGFloat)minContentHeight;

@end
