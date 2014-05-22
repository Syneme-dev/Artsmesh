//
//  AMBox.h
//  BoxLayout2
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

@property(nonatomic, readonly) AMBoxItem *firstItem;
@property(nonatomic, readonly) AMBoxItem *lastItem;
@property(nonatomic, readonly) AMBoxStyle style;
@property(nonatomic) CGFloat gapBetweenItems;
@property(nonatomic) BOOL allowBecomeEmpty;
@property(nonatomic, copy) AMBoxItem *(^prepareForAdding)(AMBoxItem *);

+ (AMBox *)hbox;
+ (AMBox *)vbox;

// designated initializer
- (instancetype)initWithFrame:(NSRect)frameRect sytle:(AMBoxStyle)style;
- (void)doBoxLayout;
- (void)dropBoxItem:(AMBoxItem *)boxItem atLocation:(NSPoint)point;
- (void)didRemoveBoxItem:(AMBoxItem *)boxItem;
// - (NSRect)enclosingRectForSubItem:(AMBoxItem *)item;

@end
