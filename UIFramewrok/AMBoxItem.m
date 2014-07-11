//
//  AMBoxItem.m
//
//  Created by lattesir on 5/20/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMBoxItem.h"
#import "AMBox.h"

NSString * const AMBoxItemType = @"com.artmesh.boxitem";

@interface AMBoxItem ()
{
    NSEvent *_mouseDownEvent;
    NSPoint _offset;
}

- (NSArray *)createDraggingItems;

@end

@implementation AMBoxItem

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        _maxSizeConstraint = NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX);
        _dragBehavior = AMDragForDropping;
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

- (void)setPreferredSize:(NSSize)preferredSize
{
    CGFloat w = preferredSize.width;
    CGFloat h = preferredSize.height;
    
    w = MIN(MAX(w, self.minSizeConstraint.width), self.maxSizeConstraint.width);
    h = MIN(MAX(h, self.minSizeConstraint.height), self.maxSizeConstraint.height);
    _preferredSize = NSMakeSize(w, h);
    [self.hostingBox doBoxLayout];
}


#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"


- (void)removeFromSuperview
{
    AMBox *hostingBox = self.hostingBox;
    [super removeFromSuperview];
    [hostingBox didRemoveBoxItem:self];
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
    NSPoint p1, p2;
    
    switch (self.dragBehavior) {
        case AMDragForDropping:
            _mouseDownEvent = theEvent;
            break;
        case AMDragForMoving:
            p1 = self.frame.origin;
            p2 = [self.superview convertPoint:[theEvent locationInWindow]
                                             fromView:nil];
            _offset = NSMakePoint(p1.x - p2.x, p1.y - p2.y);
            break;
        default:
            break;
    }
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint p, newOrigin;
    
    switch (self.dragBehavior) {
        case AMDragForDropping:
            [self beginDraggingSessionWithItems:[self createDraggingItems]
                                          event:_mouseDownEvent
                                         source:self];
            break;
        case AMDragForMoving:
            p = [self.superview convertPoint:[theEvent locationInWindow]
                                    fromView:nil];
            newOrigin.x = p.x + _offset.x;
            newOrigin.y = p.y + _offset.y;
            [self setFrameOrigin:newOrigin];
            break;
        default:
            break;
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if (_mouseDownEvent)
        _mouseDownEvent = nil;
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
    [pasteboardItem setString:@"" forType:AMBoxItemType];
    
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