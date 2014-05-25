//
//  AMBox.m
//
//  Created by lattesir on 5/20/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMBox.h"

@implementation AMBox

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
        [self registerForDraggedTypes: @[NSPasteboardTypeString]];
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

- (void)doBoxLayout
{
    CGFloat offsetX = self.paddingLeft;
    CGFloat offsetY = self.paddingTop;
    CGFloat gap = 0;
    CGFloat maxWidth = 0;
    CGFloat maxHeight = 0;
    NSSize boxSize = NSZeroSize;
    
    for (AMBoxItem *item in self.subviews) {
        if (!item.visiable)
            continue;
        NSSize itemSize = item.frame.size;
        if (self.style == AMBoxVertical) {
            offsetY += gap;
            [item setFrameOrigin:NSMakePoint(offsetX, offsetY)];
            offsetY += itemSize.height;
            maxWidth = MAX(maxWidth, itemSize.width);
        } else {
            offsetX += gap;
            [item setFrameOrigin:NSMakePoint(offsetX, offsetY)];
            offsetX += itemSize.width;
            maxHeight = MAX(maxHeight, itemSize.height);
        }
        if (gap == 0)
            gap = self.gapBetweenItems;
    }
    
    if (self.style == AMBoxVertical && maxWidth > 0) {
        boxSize = NSMakeSize(maxWidth + self.paddingLeft + self.paddingRight,
                             offsetY + self.paddingBottom);
    } else if (self.style == AMBoxHorizontal && maxHeight > 0) {
        boxSize = NSMakeSize(offsetX + self.paddingRight,
                             maxHeight + self.paddingTop + self.paddingBottom);
    }
    
    [self setFrameSize:boxSize];
}

- (void)dropBoxItem:(AMBoxItem *)boxItem atLocation:(NSPoint)point
{
    if (NSPointInRect(point, [boxItem enclosingRect]))
        return;
    
    point = [self convertPoint:point fromView:nil];
    CGFloat offsetX = self.paddingLeft;
    CGFloat offsetY = self.paddingTop;
    CGFloat gap = 0;
    AMBoxItem *belowItem = nil;
    
    for (AMBoxItem *item in self.subviews) {
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
    
    
//    if ([boxItem isDescendantOf:self]) {
//        BOOL saved = self.allowBecomeEmpty;
//        self.allowBecomeEmpty = YES;
//        [boxItem removeFromSuperview];
//        self.allowBecomeEmpty = saved;
//    } else {
//        [boxItem removeFromSuperview];
//    }
    [boxItem removeFromSuperview];
    
    if (belowItem)
        [self addSubview:boxItem positioned:NSWindowAbove relativeTo:belowItem];
    else
        [self addSubview:boxItem positioned:NSWindowBelow relativeTo:nil];
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

- (AMBoxItem *)firstItem
{
    return [self.subviews firstObject];
}

- (AMBoxItem *)lastItem
{
    return [self.subviews lastObject];
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
}

#pragma mark - dragging destination implementation

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
    id source = [sender draggingSource];
    
    if ([source isKindOfClass:[AMBoxItem class]]) {
        AMBoxItem *draggingSource = (AMBoxItem *)source;
        if (![self isDescendantOf:draggingSource]) {
            return NSDragOperationMove;
        }
    }
    
    return NSDragOperationNone;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender
{
}

- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender
{
    return YES;
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
    AMBoxItem *item = (AMBoxItem *)[sender draggingSource];
    NSPoint location = [sender draggingLocation];
    [self dropBoxItem:item atLocation:location];
    return YES;
}

@end
