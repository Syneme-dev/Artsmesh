//
//  AMBoxItem.m
//  BoxLayout2
//
//  Created by lattesir on 5/20/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMBoxItem.h"

@interface AMBoxItem ()
{
    NSEvent *_mouseDownEvent;
    BOOL _draggingSessionCreated;
}

- (NSDraggingItem *)createDraggingItem;

@end

@implementation AMBoxItem

- (id)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    if (self) {
        _maxSizeConstraint = NSMakeSize(CGFLOAT_MAX, CGFLOAT_MAX);
        _draggingSource = YES;
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

- (void)setPadding:(CGFloat)padding
{
    self.paddingLeft = padding;
    self.paddingRight = padding;
    self.paddingTop = padding;
    self.paddingBottom = padding;
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
    NSView *superview = self.superview;
    [super removeFromSuperview];
    //    self.minSizeConstraint = NSZeroSize;
    if ([superview respondsToSelector:@selector(didRemoveBoxItem:)])
        [superview performSelector:@selector(didRemoveBoxItem:) withObject:self];
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
        if ([self.superview respondsToSelector:@selector(doBoxLayout)])
            [self.superview performSelector:@selector(doBoxLayout)];
    }
}

- (void)setHidden:(BOOL)flag
{
    if (self.isHidden ^ flag) {
        [super setHidden:flag];
        if ([self.superview respondsToSelector:@selector(doBoxLayout)])
            [self.superview performSelector:@selector(doBoxLayout)];
    }
}

#pragma clang diagnostic pop


#pragma mark - dragging source implementation

- (void)mouseDown:(NSEvent *)theEvent
{
    _mouseDownEvent = theEvent;
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    if (self.draggingSource && !_draggingSessionCreated) {
        NSDraggingItem *draggingItem = [self createDraggingItem];
        [self beginDraggingSessionWithItems:@[draggingItem]
                                      event:_mouseDownEvent
                                     source:self];
        _draggingSessionCreated = YES;
    }
    return;
}

- (void)draggingSession:(NSDraggingSession *)session
           endedAtPoint:(NSPoint)screenPoint
              operation:(NSDragOperation)operation
{
    _draggingSessionCreated = NO;
    
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

- (NSDraggingItem *)createDraggingItem
{
    NSPasteboardItem *pasteboardItem = [[NSPasteboardItem alloc] init];
    [pasteboardItem setString:@"" forType:NSPasteboardTypeString];
    
    /*
     NSRect draggingRect = NSZeroRect;
     draggingRect.size = self.frame.size;
     NSImage *draggingImage = [[NSImage alloc] initWithSize:draggingRect.size];
     [draggingImage lockFocus];
     [self drawRect:draggingRect];
     [[NSColor colorWithWhite:1.0 alpha:0.5] set];
     [NSBezierPath fillRect:draggingRect];
     [draggingImage unlockFocus];
     */
    
    NSBitmapImageRep *imageRep = [self bitmapImageRepForCachingDisplayInRect:self.bounds];
    imageRep.size = self.bounds.size;
    [self cacheDisplayInRect:self.bounds toBitmapImageRep:imageRep];
    NSRect imageRect = NSZeroRect;
    imageRect.size = self.frame.size;
    NSImage* draggingImage = [[NSImage alloc] initWithSize:imageRect.size];
    [draggingImage addRepresentation:imageRep];
    [draggingImage lockFocus];
    [[NSColor colorWithWhite:1.0 alpha:0.5] set];
    [NSBezierPath fillRect:imageRect];
    [draggingImage unlockFocus];
    
    NSDraggingItem *draggingItem = [[NSDraggingItem alloc]
                                    initWithPasteboardWriter:pasteboardItem];
    [draggingItem setDraggingFrame:imageRect contents:draggingImage];
    
    return draggingItem;
}

@end