//
//  AMCollectionView.m
//  AMCollectionViewTest
//
//  Created by wangwei on 26/11/14.
//  Copyright (c) 2014 wangwei. All rights reserved.
//

#import "AMCollectionView.h"
#import "AMCollectionViewCell.h"
#define THUMBNAIL_HEIGHT 180.0 

NSString* const AMMusicScoreItemType = @"com.artsmesh.musicscoreitem";

@interface AMCollectionView()<NSDraggingDestination, NSDraggingSource>
@end

@implementation AMCollectionView
{
    NSMutableArray *_viewItems;
    NSColor* _bkColor;
    
    NSView * _docView;
    __weak NSScrollView* _scrollView;
    __weak  AMCollectionViewCell* _selectedView;
    
    NSEvent*        mouseDownEvent;
    int             mouseDownIndex;
    
   
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self doInit];
    }
    
    return self;
}

- (void)awakeFromNib
{
    [self doInit];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
//    [[NSColor blueColor] set];
//    [[NSBezierPath bezierPathWithRect:self.bounds] fill];
}

-(void) doInit
{
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame: self.bounds];
    scrollView.hasHorizontalScroller = YES;
    scrollView.autohidesScrollers = YES;
    scrollView.drawsBackground = NO;
    [self addSubview:scrollView];
    
    [scrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *views = NSDictionaryOfVariableBindings(scrollView);
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[scrollView]-0-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[scrollView]-0-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    _scrollView = scrollView;
    _docView = [[NSView alloc] initWithFrame:scrollView.contentView.bounds];
    
    scrollView.documentView = _docView;
    
    _viewItems = [[NSMutableArray alloc] init];
    

    _selectable = NO;
    _selectedView = nil;
    
   //old style [self registerForDraggedTypes:@[NSTIFFPboardType]];
    [self registerForDraggedTypes:@[AMMusicScoreItemType]];
}

-(void)setFrame:(NSRect)frame{
    [super setFrame:frame];
    
    NSRect rect = _docView.frame;
    rect.size.height = self.bounds.size.height;
    _docView.frame = rect;
    
  }

-(void)addViewItem:(NSView *)view
{
    [_viewItems addObject:view];
    [self reloadData];
}


-(void)addViewItem:(NSView *)view atIndex:(NSUInteger)index
{
    [_viewItems insertObject:view atIndex:index];
    [self reloadData];
}


-(void)reloadData
{
    [_docView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    int xPos = 0;
    NSRect rect = _docView.bounds;
    rect.size.width = xPos;
    _docView.frame = rect;

    for (NSView *subView in _viewItems) {
        NSRect rect = NSMakeRect(xPos, 0, subView.frame.size.width, _docView.bounds.size.height);
        subView.frame = rect;
        xPos += subView.frame.size.width + self.itemGap;
        
        [_docView addSubview:subView];
    }
    
    if (_docView.bounds.size.width < xPos) {
        NSRect rect = _docView.bounds;
        rect.size.width = xPos;
        _docView.frame = rect;
    }
    
    [self setNeedsDisplay:YES];
}


-(void)addViewItems:(NSArray *)views
{
    [_viewItems addObjectsFromArray:views];
    [self reloadData];
}

-(void)removeViewAtIndex:(NSUInteger)index
{
    [_viewItems removeObjectAtIndex:index];
    [self reloadData];
}


-(void)removeViewItem:(NSView *)view
{
    [_viewItems removeObject:view];
    [self reloadData];
}


-(void)removeAllItems
{
    [_viewItems removeAllObjects];
    [self reloadData];
}

-(void)setBackgroudColor:(NSColor *)backgroudColor
{
    _bkColor = backgroudColor;
    if (_bkColor && _scrollView) {
        _scrollView.drawsBackground = YES;
        _scrollView.backgroundColor = _bkColor;
    }else if(_scrollView){
        _scrollView.drawsBackground = NO;
    }
}


-(NSColor *)backgroudColor
{
    return _bkColor;
}


- (NSDragOperation) draggingSourceOperationMaskForLocal:(BOOL)flag
{
    if (flag) {
        return NSDragOperationMove;
    }
    return NSDragOperationDelete;
}

- (void) removeSelectedItem
{
    if (!_selectable && _selectedView == nil)
        return;
    
    [self removeViewItem:_selectedView];
    _selectedView = nil;
}

- (void) mouseDown:(NSEvent *)theEvent
{
    mouseDownIndex = -1;
    mouseDownEvent  = theEvent;
    
    NSPoint mouseDownPoint = [theEvent locationInWindow];
    AMCollectionViewCell* mouseDownView  = [self hitTest:mouseDownPoint];
    
    for (AMCollectionViewCell* viewItem in _viewItems) {
        if(mouseDownView == viewItem){
            mouseDownIndex = [_viewItems indexOfObject:viewItem];
        }
    }
    
    if (_selectable) {
        if (_selectedView == nil) {
            [mouseDownView setSelected:YES];
            _selectedView = mouseDownView;
        }
        else if(_selectedView == mouseDownView){
            [_selectedView setSelected:NO];
            _selectedView = nil;
        }
        else {
            [_selectedView setSelected:NO];
            [mouseDownView setSelected:YES];
            _selectedView = mouseDownView;
        }
    }
    
}

- (void) mouseDragged:(NSEvent *)theEvent
{
    if(mouseDownIndex < 0){
        return;
    }
    
    NSPoint downPoint = [mouseDownEvent locationInWindow];
    NSPoint dragPoint = [theEvent       locationInWindow];
    float distance = hypot(downPoint.x - dragPoint.x, downPoint.y - dragPoint.y);
    if(distance < 3)
        return;
    
    NSView* view = [_viewItems objectAtIndex:mouseDownIndex];
    
    if(view == nil)
        return;
    // generate semi-transparent thumbnail
    NSBitmapImageRep *imageRep = [view bitmapImageRepForCachingDisplayInRect:view.bounds];
    
   imageRep.size = view.bounds.size;
    [view cacheDisplayInRect:view.bounds toBitmapImageRep:imageRep];
    NSRect imageRect = NSZeroRect;
    imageRect.size = view.frame.size;
    NSImage* draggingImage = [[NSImage alloc] initWithSize:imageRect.size];
    [draggingImage addRepresentation:imageRep];
    [draggingImage lockFocus];
    [[NSColor colorWithWhite:1.0 alpha:0.3] set];
    [NSBezierPath fillRect:imageRect];
    [draggingImage unlockFocus];//*/
    
    
    NSRect  thumbRect = NSZeroRect;
    thumbRect.size = [self thumbnailSize:draggingImage];
    NSPoint p = [self convertPoint:downPoint fromView:nil];
    p.x = p.x - thumbRect.size.width/2;
    p.y = p.y - thumbRect.size.height/2;
    
    thumbRect.origin.x = p.x;
    thumbRect.origin.y = p.y;

    
  /*  old style
   NSPasteboard *pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
   [pboard declareTypes:[NSArray arrayWithObject:NSTIFFPboardType]  owner:self];
   [pboard setData:[draggingImage TIFFRepresentation] forType:NSTIFFPboardType];
   
   [self dragImage:draggingImage
                 at:p
             offset:NSZeroSize
              event:mouseDownEvent
         pasteboard:pb
             source:self
          slideBack:YES];*/
    
    NSPasteboardItem *pasteboardItem = [[NSPasteboardItem alloc] init];
    [pasteboardItem setString:@"" forType:AMMusicScoreItemType];
    
    
    NSDraggingItem *draggingItem = [[NSDraggingItem alloc]
                                    initWithPasteboardWriter:pasteboardItem];
    [draggingItem setDraggingFrame:thumbRect contents:draggingImage];
    
    [self beginDraggingSessionWithItems:@[draggingItem]
                                  event:mouseDownEvent
                                 source:self];

    
}

- (NSView*) viewByHit:(NSPoint)down
{
    return nil;
}

-(NSSize) thumbnailSize : (NSImage*) image
{
    NSSize imageSize = [image size];
    CGFloat imageAspectRatio = imageSize.width / imageSize.height;
    // Create a thumbnail image from this image (this part of the slow operation)
    NSSize thumbnailSize = NSMakeSize(THUMBNAIL_HEIGHT * imageAspectRatio, THUMBNAIL_HEIGHT);
    
    return thumbnailSize;
}

- (NSDragOperation) draggingEntered:(id<NSDraggingInfo>)sender
{
    
    
    if ([sender draggingSource] == self) {
        return NSDragOperationMove;
    }
    return NSDragOperationDelete;
}

-(void) draggingExited:(id<NSDraggingInfo>)sender
{
}

- (BOOL) prepareForDragOperation:(id<NSDraggingInfo>)sender
{
    return YES;
}

- (void) concludeDragOperation:(id<NSDraggingInfo>) sender
{
    NSLog(@"concludeDragOperation");
}

- (BOOL) performDragOperation:(id<NSDraggingInfo>)sender
{
    if([sender draggingSourceOperationMask] & NSDragOperationDelete > 0)
    {
        NSLog(@"Just Delete");
    }
    
    NSView* sourceView  = [_viewItems objectAtIndex:mouseDownIndex];
    NSPoint location    = [sender draggingLocation];
    NSView* destView    = [self hitTest:location];
    if(destView == nil || ![_viewItems containsObject:destView] || destView == sourceView) {
        return NO;
    }
    
    NSPoint mouseDownPoint = [mouseDownEvent locationInWindow];
    NSUInteger destIndex = [_viewItems indexOfObject:destView];
    
    [_viewItems removeObject:sourceView];
    [_viewItems insertObject:sourceView atIndex:destIndex];
    [self reloadData];
    
    return YES;
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

@end
