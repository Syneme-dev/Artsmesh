//
//  AMScoreCollectionView.m
//  Artsmesh
//
//  Created by whiskyzed on 3/23/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//
#import "AMTimerTabVC.h"
#import "AMScoreCollectionView.h"
#import "AMScoreCollectionCell.h"
#import "AMNowBarView.h"
#import "UIFramework/NSView_Constrains.h"
#define THUMBNAIL_HEIGHT 180.0

NSString* const AMMusicScoreType = @"com.artsmesh.musicscore";

@interface AMScoreCollectionView()<NSDraggingDestination, NSDraggingSource>
@end

@implementation AMScoreCollectionView
{
    NSMutableArray *_viewItems;
    NSColor* _bkColor;
    
    NSView * _docView;
    __weak NSScrollView* _scrollView;
    __weak  AMScoreCollectionCell* _selectedView;
    
    NSEvent*        mouseDownEvent;
    int             mouseDownIndex;
    
    NSTimer*        _scrollTimer;
    AMNowBarView*   _nowBarView;
    
    NSInteger        _curPageNumber;
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
    [self registerForDraggedTypes:@[AMMusicScoreType]];
    
    NSRect rect = [self bounds];
    NSRect nowBarFrame = NSMakeRect(rect.size.width /3, 0, 8, rect.size.height);
    _nowBarView = [[AMNowBarView alloc] initWithFrame:nowBarFrame];
    [self addSubview:_nowBarView];
    

    NSString *hConstrain = [NSString stringWithFormat:@"H:|-400-[_nowBarView(==%f)]",8.0];
    NSString *vConstrain = [NSString stringWithFormat:@"V:|-0-[_nowBarView]-0-|"];
    [_nowBarView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *barViews = NSDictionaryOfVariableBindings(_nowBarView);
    
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:hConstrain
                                             options:0
                                             metrics:nil
                                               views:barViews]];
    
    [self addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:vConstrain
                                             options:0
                                             metrics:nil
                                               views:barViews]];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onStartTimer:)
                                                 name:AMTimerStartNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onStopTimer:)
                                                 name:AMTimerStopNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter]  addObserver:self
                                              selector:@selector(onPauseTimer:)
                                                  name:AMTimerPauseNotification
                                                object:nil];
    
    [[NSNotificationCenter  defaultCenter]   addObserver:self
                                                selector:@selector(onResumeTimer:)
                                                    name:AMTimerResumeNotification
                                                  object:nil];

    [self setMode:0];
    _scrollDelta = 100;
    _timeInterval = 2;
}

- (void) dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AMTimerStartNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AMTimerStopNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AMTimerPauseNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AMTimerResumeNotification
                                                  object:nil];
    
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
    //    [_docView addSubview:_nowBarView];
    
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
    // get the current scroll position of the document view
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
    AMScoreCollectionCell* mouseDownView  = [self hitTest:mouseDownPoint];
    
    for (AMScoreCollectionCell* viewItem in _viewItems) {
        if(mouseDownView == viewItem){
            mouseDownIndex = [_viewItems indexOfObject:viewItem];
        }
    }
}

- (void) mouseUp:(NSEvent *)theEvent
{
    NSPoint mouseDownPoint = [mouseDownEvent locationInWindow];
    AMScoreCollectionCell* mouseDownView  = [self hitTest:mouseDownPoint];
    
    /*
    for (AMScoreCollectionCell* viewItem in _viewItems) {
        if(mouseDownView == viewItem){
            mouseDownIndex = [_viewItems indexOfObject:viewItem];
        }
    }*/
    
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
    
    [self autoscroll:theEvent];
    
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
    [pasteboardItem setString:@"" forType:AMMusicScoreType];
    
    
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



#pragma mark -
#pragma mark AMTimerNotificatio
- (void) onStartTimer : (NSNotification*) notfication
{
    [_scrollTimer invalidate];
    
    if (self.mode == 1) {
        _curPageNumber = 0;
    }
    
    if (self.mode == 0 && _scrollDelta > 0) {
       // [self onStopTimer:notfication];
        _scrollTimer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                        target:self
                                                      selector:@selector(startScrollScore)
                                                      userInfo:nil
                                                       repeats:YES];

    }
    else if(self.mode == 1 && _timeInterval > 0){
        
        _scrollTimer = [NSTimer scheduledTimerWithTimeInterval:_timeInterval
                                                        target:self
                                                      selector:@selector(turnPageScore)
                                                      userInfo:nil
                                                       repeats:YES];
        
    }
}

- (void) onStopTimer : (NSNotification*) notfication
{
    [_scrollTimer invalidate];
    
    NSPoint currentScrollPosition=[[_scrollView contentView] bounds].origin;
    currentScrollPosition.x = 0;
    [[_scrollView documentView] scrollPoint:currentScrollPosition];
    
     if (self.mode == 1) {
         _curPageNumber = 0;
     }
}

- (void) onPauseTimer : (NSNotification*) notfication
{
    [_scrollTimer invalidate];
}

- (void) onResumeTimer : (NSNotification*) notfication
{
    if (self.mode == 0) {
        // [self onStopTimer:notfication];
        _scrollTimer = [NSTimer scheduledTimerWithTimeInterval:0.01
                                                        target:self
                                                      selector:@selector(startScrollScore)
                                                      userInfo:nil
                                                       repeats:YES];
        
    }
    else{
        
        _scrollTimer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval
                                                        target:self
                                                      selector:@selector(turnPageScore)
                                                      userInfo:nil
                                                       repeats:YES];
        
    }
}

- (void) startScrollScore
{
    NSPoint currentScrollPosition=[[_scrollView contentView] bounds].origin;
     currentScrollPosition.x += _scrollDelta*0.01;
     [[_scrollView documentView] scrollPoint:currentScrollPosition];
}

- (void) turnPageScore
{
    NSPoint currentScrollPosition=[[_scrollView contentView] bounds].origin;
    currentScrollPosition.x += [_scrollView bounds].size.width;
    [[_scrollView documentView] scrollPoint:currentScrollPosition];
    
/*    NSPoint currentScrollPosition=[[_scrollView contentView] bounds].origin;
    NSView* view = [_viewItems objectAtIndex:_curPageNumber];
    CGFloat pageWidth = [view bounds].size.width + _itemGap;
    
    currentScrollPosition.x += pageWidth;
    [[_scrollView documentView] scrollPoint:currentScrollPosition];
    _curPageNumber++;*/
}

- (void) setNowBarPosition:(int)pos
{
    if (pos > 100 && pos < 0) {
        return;
    }
    int collLength = [self bounds].size.width - [_nowBarView bounds].size.width;
    int position  = pos / 100.0 * collLength;
    
    NSRect barRect = [_nowBarView frame];
    barRect.origin.x = position;
    [_nowBarView setFrame:barRect];

}

@end
