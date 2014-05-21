//
//  AMBox.m
//  BoxLayout2
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
        self.draggingSource = NO;
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
    
    if ([boxItem isDescendantOf:self]) {
        BOOL saved = self.allowBecomeEmpty;
        self.allowBecomeEmpty = YES;
        [boxItem removeFromSuperview];
        self.allowBecomeEmpty = saved;
    } else {
        [boxItem removeFromSuperview];
    }
    
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

/*
- (NSRect)enclosingRectForSubItem:(AMBoxItem *)item
{
    NSRect rect = NSZeroRect;
    CGFloat dX, dY;
    
    if (item.superview == self) {
        rect = item.frame;
        if (self.style == AMBoxVertical) {
            dX = -self.paddingLeft;
            dY = (item == self.firstItem) ? -self.paddingTop : -self.gapBetweenItems;
            rect = NSOffsetRect(rect, dX, dY);
            dX = -dX + self.paddingRight;
            dY = (item == self.lastItem) ? -dY + self.paddingBottom : -dY + self.gapBetweenItems;
            rect = NSInsetRect(rect, dX, dY);
        } else {
            dX = (item == self.firstItem) ? -self.paddingLeft : -self.gapBetweenItems;
            dY = -self.paddingTop;
            rect = NSOffsetRect(rect, dX, dY);
            dX = (item == self.lastItem) ? -dX + self.paddingRight : -dX + self.gapBetweenItems;
            dY = -dY + self.paddingBottom;
            rect = NSInsetRect(rect, dX, dY);
        }
    }
    return rect;
}
 */

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
    NSPoint location = [self convertPoint:[sender draggingLocation] fromView:nil];
    [self dropBoxItem:item atLocation:location];
    return YES;
}

@end
