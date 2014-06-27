//
//  AMBox.m
//
//  Created by lattesir on 5/20/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMBox.h"

@implementation AMBox
{
    NSRect _rectForPromptLine;
}

- (instancetype)initWithFrame:(NSRect)frameRect
{
    return [self initWithFrame:frameRect sytle:AMBoxVertical];
}

- (instancetype)initWithFrame:(NSRect)frameRect sytle:(AMBoxStyle)style
{
    self = [super initWithFrame:NSZeroRect];
    if (self) {
        _style = style;
        self.dragBehavior = AMDragForNone;
        [self registerForDraggedTypes: @[AMBoxItemType]];
    }
    return self;
}

+ (AMBox *)hbox
{
    return [[AMBox alloc] initWithFrame:NSZeroRect sytle:AMBoxHorizontal];
}

+ (AMBox *)vbox
{
    return [[AMBox alloc] initWithFrame:NSZeroRect sytle:AMBoxVertical];
}


- (void)setPadding:(CGFloat)padding
{
    self.paddingLeft = padding;
    self.paddingRight = padding;
    self.paddingTop = padding;
    self.paddingBottom = padding;
}

- (CGFloat)minContentHeight
{
    CGFloat offsetY = 0;
    CGFloat gap = 0;
    
    for (AMBoxItem *item in self.subviews) {
        if (!item.visiable)
            continue;
        CGFloat itemMinHeight = 0;
        if ([item isKindOfClass:[AMBox class]])
            itemMinHeight = item.frame.size.height;
        else
            itemMinHeight = item.minSizeConstraint.height;
        if (self.style == AMBoxVertical) {
            offsetY += gap + itemMinHeight;
        } else {
            offsetY = MAX(offsetY, itemMinHeight);
        }
        if (gap == 0)
            gap = self.gapBetweenItems;
    }
    
    return offsetY;
}

- (void)doBoxLayout
{
    CGFloat offsetX = self.paddingLeft;
    CGFloat offsetY = self.paddingTop;
    CGFloat gap = 0;
    CGFloat boxWidth = 0;
    CGFloat boxHeight = self.frame.size.height;
    CGFloat freeSpace = boxHeight - [self minContentHeight] -
                            self.paddingTop - self.paddingBottom;
    NSAssert(freeSpace >= 0, @"freeSpace must be greater than zero");
    AMBoxItem *lastItem = self.lastVisibleItem;
    
    for (AMBoxItem *item in self.subviews) {
        if (!item.visiable)
            continue;
        
        if (self.style == AMBoxVertical) {
            offsetY += gap;
            [item setFrameOrigin:NSMakePoint(offsetX, offsetY)];
            NSSize itemSize = NSZeroSize;
            if ([item isKindOfClass:[AMBox class]]) {
                itemSize = item.frame.size;
            } else {
                itemSize = NSMakeSize(item.preferredSize.width,
                                      item.minSizeConstraint.height);
                CGFloat additionalSpace = freeSpace;
                if (item != lastItem)
                    additionalSpace = MIN(additionalSpace,
                        item.preferredSize.height - item.minSizeConstraint.height);
                if (additionalSpace > 0) {
                    freeSpace -= additionalSpace;
                    itemSize.height += additionalSpace;
                }
                [item setFrameSize:itemSize];
            }
            offsetY += itemSize.height;
            boxWidth = MAX(boxWidth, itemSize.width);
        } else {
            offsetX += gap;
            [item setFrameOrigin:NSMakePoint(offsetX, offsetY)];
            NSSize itemSize = NSZeroSize;
            if ([item isKindOfClass:[AMBox class]]) {
                itemSize = item.frame.size;
            } else {
                itemSize = NSMakeSize(item.preferredSize.width,
                            boxHeight - self.paddingTop - self.paddingBottom);
                [item setFrameSize:itemSize];
            }
            offsetX += itemSize.width;
            boxWidth = offsetX - self.paddingLeft;
        }
        if (gap == 0)
            gap = self.gapBetweenItems;
    }

    NSSize newBoxSize = NSMakeSize(boxWidth + self.paddingLeft + self.paddingRight, boxHeight);
    if (!NSEqualSizes(self.frame.size, newBoxSize)) {
        [self setFrameSize:newBoxSize];
        [self.hostingBox doBoxLayout];
    }
}

- (AMBoxItem *)boxItemBelowPoint:(NSPoint)point
{
    point = [self convertPoint:point fromView:nil];
    CGFloat offsetX = self.paddingLeft;
    CGFloat offsetY = self.paddingTop;
    CGFloat gap = 0;
    AMBoxItem *belowItem = nil;
    
    for (AMBoxItem *item in self.subviews) {
        if (!item.visiable)
            continue;
        if (self.style == AMBoxVertical) {
            offsetY += gap;
            if (offsetY > point.y)
                break;
            offsetY += item.frame.size.height;
        } else {
            offsetX += gap;
            if (offsetX > point.x)
                break;
            offsetX += item.frame.size.width;
        }
        belowItem = item;
        if (gap == 0)
            gap = self.gapBetweenItems;
    }
    return belowItem;
}

- (BOOL)dropBoxItem:(AMBoxItem *)boxItem atLocation:(NSPoint)point
{
    if (NSPointInRect(point, [boxItem enclosingRect]))
        return YES;
    
    [boxItem removeFromSuperview];
    if (self.style == AMBoxVertical) {
        CGFloat freeSpace = self.frame.size.height - self.paddingBottom -
            self.paddingTop - self.gapBetweenItems - [self minContentHeight];
        if (freeSpace < boxItem.minSizeConstraint.height)
            return NO;
    }
    
    AMBoxItem *belowItem = [self boxItemBelowPoint:point];
    if (belowItem)
        [self addSubview:boxItem positioned:NSWindowAbove relativeTo:belowItem];
    else
        [self addSubview:boxItem positioned:NSWindowBelow relativeTo:nil];
    return YES;
}

- (void)didRemoveBoxItem:(AMBoxItem *)boxItem
{
    if ([self.subviews count] == 0) {
        if (!self.allowBecomeEmpty)
            [self removeFromSuperview];
        return;
    }
    [self doBoxLayout];
}

- (AMBoxItem *)firstVisibleItem
{
    for (AMBoxItem *item in self.subviews) {
        if (item.visiable)
            return item;
    }
    return nil;
}

- (AMBoxItem *)lastVisibleItem
{
    for (AMBoxItem *item in [self.subviews reverseObjectEnumerator]) {
        if (item.visiable)
            return item;
    }
    return nil;
}

#pragma mark - overridden methods

- (void)addSubview:(NSView *)aView
{
    if ([aView isKindOfClass:[AMBoxItem class]]) {
        AMBoxItem *item = (AMBoxItem *)aView;
        AMBoxItem *preparedItem = (self.prepareForAdding) ?
            self.prepareForAdding(item) : nil;
        if (preparedItem)
            item = preparedItem;
        [super addSubview:item];
        [self doBoxLayout];
    }
}

- (void)addSubview:(NSView *)aView
        positioned:(NSWindowOrderingMode)place
        relativeTo:(NSView *)otherView
{
    if ([aView isKindOfClass:[AMBoxItem class]]) {
        AMBoxItem *item = (AMBoxItem *)aView;
        AMBoxItem *preparedItem = (self.prepareForAdding) ?
            self.prepareForAdding(item) : nil;
        if (preparedItem)
            item = preparedItem;
        [super addSubview:item positioned:place relativeTo:otherView];
        [self doBoxLayout];
    }
}

- (BOOL)isFlipped
{
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
//    [[NSColor blueColor] set];
//    [NSBezierPath setDefaultLineWidth:2];
//    [NSBezierPath strokeRect:self.bounds];
//    [[NSColor redColor] set];
//    [NSBezierPath fillRect:self.bounds];
    if (!NSEqualRects(NSZeroRect, _rectForPromptLine)) {
        NSBezierPath *path = [NSBezierPath bezierPath];
        CGFloat x = _rectForPromptLine.origin.x;
        CGFloat y = _rectForPromptLine.origin.y;
        CGFloat w = _rectForPromptLine.size.width;
        CGFloat h = _rectForPromptLine.size.height;
        if (self.style == AMBoxVertical) {
            [path appendBezierPathWithOvalInRect:NSMakeRect(x, y, h, h)];
            [path moveToPoint:NSMakePoint(x + h, y + h / 2)];
            [path lineToPoint:NSMakePoint(x + w, y + h / 2)];
        } else {
            [path appendBezierPathWithOvalInRect:NSMakeRect(x, y, w, w)];
            [path moveToPoint:NSMakePoint(x + w / 2, y + w)];
            [path lineToPoint:NSMakePoint(x + w / 2, y + h)];
        }
        [[NSColor colorWithRed:0.43 green:0.62 blue:0.93 alpha:1.0] set];
        [NSBezierPath setDefaultLineWidth:1.0];
        [path stroke];
    }
}

#pragma mark - dragging destination implementation

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    /*
    id source = [sender draggingSource];
    
    if ([source isKindOfClass:[AMBoxItem class]]) {
        AMBoxItem *draggingSource = (AMBoxItem *)source;
        if (![self isDescendantOf:draggingSource]) {
            return NSDragOperationMove;
        }
    }
    
    return NSDragOperationNone;
     */
    return NSDragOperationMove;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender
{
    //AMBoxItem *item = (AMBoxItem *)[sender draggingSource];
    NSPoint location = [sender draggingLocation];
    NSRect rect = NSZeroRect;
    AMBoxItem *belowItem = [self boxItemBelowPoint:location];
    if (belowItem) {
        NSPoint origin = belowItem.frame.origin;
        NSSize size = belowItem.frame.size;
        if (self.style == AMBoxVertical) {
            rect = NSMakeRect(0, origin.y + size.height + self.gapBetweenItems / 2,
                              self.frame.size.width, 6);
        } else {
            rect = NSMakeRect(origin.x + size.width + 10 + self.gapBetweenItems / 2, 0,
                              6, self.frame.size.height);
        }
    } else {
        if (self.style == AMBoxVertical) {
            rect = NSMakeRect(0, self.paddingTop / 2,
                              self.frame.size.width - 6, 6);
        } else {
            rect = NSMakeRect(self.paddingLeft / 2, 0,
                              6, self.frame.size.height - 6);
        }
    }
    if (!NSEqualRects(rect, _rectForPromptLine)) {
        _rectForPromptLine = rect;
        self.needsDisplay = YES;
    }
    return NSDragOperationMove;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender
{
    if (!NSEqualRects(NSZeroRect, _rectForPromptLine)) {
        _rectForPromptLine = NSZeroRect;
        self.needsDisplay = YES;
    }
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender
{
    return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
    AMBoxItem *item = (AMBoxItem *)[sender draggingSource];
    NSPoint location = [sender draggingLocation];
    BOOL canDrop = [self dropBoxItem:item atLocation:location];
    if (!NSEqualRects(NSZeroRect, _rectForPromptLine)) {
        _rectForPromptLine = NSZeroRect;
        self.needsDisplay = YES;
    }
    return canDrop;
}

@end
