//
//  AMBoxItem.m
//
//  Created by lattesir on 5/20/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMBoxItem.h"
#import "AMBox.h"

@interface AMBoxItem ()
{
    NSEvent *_mouseDownEvent;
}

- (NSArray *)createDraggingItems;

@end

@implementation AMBoxItem

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        _maxSizeConstraint = NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX);
        _dragBehavior = AMDragForMoving;
    }
    return self;
}

- (BOOL)visiable
{
    if (!self.isHidden) {
        NSSize size = self.frame.size;
        return size.width > 0 && size.height > 0;
    }
    
    return NO;
}

- (AMBox *)hostingBox
{
    if ([self.superview isKindOfClass:[AMBox class]])
        return (AMBox *)self.superview;
    else
        return nil;
}

- (NSRect)enclosingRect
{
    AMBox *hostingBox = self.hostingBox;
    if (!hostingBox || !self.visiable)
        return NSZeroRect;
    
    int count = 0;
    for (AMBoxItem *item in hostingBox.subviews) {
        if (item.visiable)
            count++;
    }
    if (count == 1)
        return [hostingBox enclosingRect];
    
    NSPoint origin = self.frame.origin;
    NSSize size = self.frame.size;
    CGFloat x1 = 0, y1 = 0;
    CGFloat x2 = hostingBox.bounds.size.width;
    CGFloat y2 = hostingBox.bounds.size.height;
    if (hostingBox.style == AMBoxVertical) {
        if (self != hostingBox.firstVisibleItem)
            y1 = origin.y - hostingBox.gapBetweenItems;
        if (self != hostingBox.lastVisibleItem)
            y2 = origin.y + size.height + hostingBox.gapBetweenItems;
        NSRect rect = NSMakeRect(x1, y1, x2 - x1, y2 - y1);
        return [hostingBox convertRect:rect toView:nil];
    } else {
        if (self != hostingBox.firstVisibleItem)
            x1 = origin.x - hostingBox.gapBetweenItems;
        if (self != hostingBox.lastVisibleItem)
            x2 = origin.x + size.width + hostingBox.gapBetweenItems;
        NSRect rect = NSMakeRect(x1, y1, x2 - x1, y2 - y1);
        return [hostingBox convertRect:rect toView:nil];
    }
}

- (void)setMinSizeConstraint:(NSSize)minSizeConstraint
{
    _minSizeConstraint = minSizeConstraint;
    NSSize frameSize = self.frame.size;
    frameSize = NSMakeSize(MAX(_minSizeConstraint.width, frameSize.width),
                           MAX(_minSizeConstraint.height, frameSize.height));
    [self setFrameSize:frameSize];
}

- (void)setMaxSizeConstraint:(NSSize)maxSizeConstraint
{
    _maxSizeConstraint = maxSizeConstraint;
    NSSize frameSize = self.frame.size;
    frameSize = NSMakeSize(MIN(_maxSizeConstraint.width, frameSize.width),
                           MIN(_maxSizeConstraint.height, frameSize.height));
    [self setFrameSize:frameSize];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"

- (void)removeFromSuperview
{
    AMBox *hostingBox = self.hostingBox;
    [super removeFromSuperview];
    [hostingBox didRemoveBoxItem:self];
}

- (void)setFrame:(NSRect)frameRect
{
    return [self setFrameSize:frameRect.size];
}

- (void)setFrameSize:(NSSize)newSize
{
    NSSize oldSize = self.frame.size;
    NSSize minSize = self.minSizeConstraint;
    NSSize maxSize = self.maxSizeConstraint;
    
    newSize = NSMakeSize(
                         MIN(MAX(minSize.width, newSize.width), maxSize.width),
                         MIN(MAX(minSize.height, newSize.height), maxSize.height));
    if (!NSEqualSizes(oldSize, newSize)) {
        [super setFrameSize:newSize];
        [self.hostingBox doBoxLayout];
    }
}

- (void)setHidden:(BOOL)flag
{
    if (self.isHidden ^ flag) {
        [super setHidden:flag];
        [self.hostingBox doBoxLayout];
    }
}

- (void)resizeByDraggingLocation:(NSPoint)location
{
    return;
}

#pragma clang diagnostic pop


#pragma mark - dragging and resizing implementation

- (void)mouseDown:(NSEvent *)theEvent
{
    _mouseDownEvent = theEvent;
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    switch (self.dragBehavior) {
        case AMDragForMoving:
            [self beginDraggingSessionWithItems:[self createDraggingItems]
                                          event:_mouseDownEvent
                                         source:self];
            break;
        case AMDragForResizing:
            [self resizeByDraggingLocation:[theEvent locationInWindow]];
            break;
        default:
            break;
    }
}

- (void)draggingSession:(NSDraggingSession *)session
           endedAtPoint:(NSPoint)screenPoint
              operation:(NSDragOperation)operation
{
    if (operation == NSDragOperationDelete) {
        [self removeFromSuperview];
        return;
    }
}

- (NSDragOperation)draggingSession:(NSDraggingSession *)session
sourceOperationMaskForDraggingContext:(NSDraggingContext)context
{
    switch (context) {
        case NSDraggingContextOutsideApplication:
            return NSDragOperationDelete;
            // by using this fall through pattern, we will remain compatible
            // if the contexts get more precise in the future.
        case NSDraggingContextWithinApplication:
        default:
            return NSDragOperationMove;
    }
}

- (NSArray *)createDraggingItems
{
    NSPasteboardItem *pasteboardItem = [[NSPasteboardItem alloc] init];
    [pasteboardItem setString:@"" forType:NSPasteboardTypeString];
    
    // generate semi-transparent thumbnail
    NSBitmapImageRep *imageRep = [self bitmapImageRepForCachingDisplayInRect:self.bounds];
    imageRep.size = self.bounds.size;
    [self cacheDisplayInRect:self.bounds toBitmapImageRep:imageRep];
    NSRect imageRect = NSZeroRect;
    imageRect.size = self.frame.size;
    NSImage* draggingImage = [[NSImage alloc] initWithSize:imageRect.size];
    [draggingImage addRepresentation:imageRep];
    [draggingImage lockFocus];
    [[NSColor colorWithWhite:1.0 alpha:0.3] set];
    [NSBezierPath fillRect:imageRect];
    [draggingImage unlockFocus];
    
    NSDraggingItem *draggingItem = [[NSDraggingItem alloc]
                                    initWithPasteboardWriter:pasteboardItem];
    [draggingItem setDraggingFrame:imageRect contents:draggingImage];
    
    return @[draggingItem];
}

@end