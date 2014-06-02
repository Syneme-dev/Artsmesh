//
//  AMBoxItem.h
//
//  Created by lattesir on 5/20/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AMBox;

extern NSString * const AMBoxItemType;

typedef NS_ENUM(NSUInteger, AMDragBehavior) {
    AMDragForNone,
    AMDragForMoving,
    AMDragForResizing
};

@interface AMBoxItem : NSView<NSDraggingSource>

@property(nonatomic) NSSize minSizeConstraint;
@property(nonatomic) NSSize maxSizeConstraint;
@property(nonatomic) AMDragBehavior dragBehavior;
@property(nonatomic, readonly) BOOL visiable;
@property(nonatomic, readonly) AMBox *hostingBox;

- (NSRect)enclosingRect;
- (void)resizeByDraggingLocation:(NSPoint)location;


@end