//
//  AMCollectionView.m
//  AMCollectionViewTest
//
//  Created by wangwei on 26/11/14.
//  Copyright (c) 2014 wangwei. All rights reserved.
//

#import "AMCollectionView.h"

@implementation AMCollectionView
{
    NSMutableArray *_viewItems;
    NSColor* _bkColor;
    
    NSView * _docView;
    __weak NSScrollView* _scrollView;
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
}

-(void)setFrame:(NSRect)frame{
    [super setFrame:frame];
    
    NSRect rect = _docView.frame;
    rect.size.height = self.bounds.size.height;
    _docView.frame = rect;
}

-(void)addViewItem:(NSView *)view
{
    int xPos = 0;
    for (NSView *viewItem in _viewItems) {
        xPos += viewItem.frame.size.width + self.itemGap;
    }
    
    NSRect rect = NSMakeRect(xPos, 0, view.frame.size.width, _docView.bounds.size.height);
    view.frame = rect;
    
    if (_docView.bounds.size.width < xPos + view.frame.size.width + self.itemGap) {
        NSRect rect = _docView.bounds;
        rect.size.width = xPos + view.frame.size.width + self.itemGap;
        _docView.frame = rect;
    }
    
    [_viewItems addObject:view];
    [_docView addSubview:view];
    [self setNeedsDisplay:YES];
}

-(void)addViewItems:(NSArray *)views
{
    for (NSView *view in views) {
        [self addSubview:view];
    }
}

-(void)removeAllItems
{
    for (NSView *view in _viewItems) {
        [view removeFromSuperview];
    }
    
    [_viewItems removeAllObjects];
    
    [self setNeedsDisplay:YES];
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

@end
