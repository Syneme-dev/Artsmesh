//
//  AMPopUpView.m
//  MyPopUpTest
//
//  Created by 王 为 on 7/31/14.
//  Copyright (c) 2014 王 为. All rights reserved.
//

#import "AMPopUpView.h"
#import "AMPopUpMenuController.h"
#import "NSView_Constrains.h"

@interface AMPopUpView()<AMPopUpMenuDelegate, NSWindowDelegate>

@property BOOL mouseEntered;
@property(nonatomic) NSInteger indexOfSelectedItem;

@property NSWindow *popWindow;

@end

@implementation AMPopUpView
{
    NSString* _title;
    AMPopUpMenuController* _popUpMenuController;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
        self.backgroupColor = [NSColor colorWithCalibratedRed:(38.0f/255.0f)
                                                        green:(38.0f/255.0f)
                                                         blue:(38.0f/255.0f)
                                                        alpha:1];
        self.mouseOverColor = [NSColor colorWithCalibratedRed:(30.0f/255.0f)
                                                        green:(30.0f/255.0f)
                                                         blue:(30.0f/255.0f)
                                                        alpha:1];
        _title = @"";
        _indexOfSelectedItem = -1;
        self.textColor = [NSColor whiteColor];
        self.font = [NSFont fontWithName: @"FoundryMonoline-Bold" size: self.font.pointSize];
        
        self.itemWidth = 0;
        self.itemHeight = 30;
    
        [self addTrackingRect:self.bounds owner:self userData:nil assumeInside:NO];
    }
    return self;
}


- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    //Drawing border and background
    NSBezierPath *border = [NSBezierPath bezierPathWithRoundedRect:self.bounds
                                                           xRadius:5 yRadius:5];
    [[NSColor colorWithRed:69/255.0 green:69/255.0 blue:74/255.0 alpha:1.0] set];
    [border stroke];
    
    
    // Drawing title
    NSMutableDictionary *textAttributes = [[NSMutableDictionary alloc] init];
    
    if (self.font) {
        textAttributes[NSFontAttributeName] = self.font;
    }
    
    if (self.textColor) {
        textAttributes[NSForegroundColorAttributeName] = self.textColor;
    }
    
    NSSize fontSize = [_title sizeWithAttributes:textAttributes];
    NSPoint titleLocation = NSMakePoint(10, (self.bounds.size.height - fontSize.height) /2);
    [_title drawAtPoint:titleLocation withAttributes:textAttributes];
    
    //Dawing Triangle
    NSRect contentRect = self.bounds;
    CGFloat imageSize = (contentRect.size.height - 5)/2;
    
    NSRect rect = NSMakeRect(contentRect.origin.x + contentRect.size.width - 20 - imageSize, contentRect.origin.y + 5, imageSize, imageSize);
    
    NSImage* triangle = [NSImage imageNamed:@"popUpTriangle"];
    [triangle drawAtPoint:rect.origin fromRect:NSZeroRect operation:NSCompositePlusLighter fraction:1.0];
    
}


-(NSWindow *)getPopWindow:(NSRect)frame
{
    if (self.popWindow == nil) {
        self.popWindow = [[NSWindow alloc] initWithContentRect:frame
                                                           styleMask:NSBorderlessWindowMask
                                                             backing:NSBackingStoreBuffered
                                                            defer:NO];
        self.popWindow.hasShadow = NO;
        self.popWindow.delegate = self;
        self.popWindow.level     = NSPopUpMenuWindowLevel;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popUpResignKeyWindow:) name:
         NSWindowDidResignKeyNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popUpWillShow:) name:
         AMPopUpWillShowNotification object:nil];
    }
    
    [self.popWindow setFrame:frame display:NO];
    return self.popWindow;
}

-(void)popUpWillShow:(NSNotification *)notification
{
    if([notification.object isNotEqualTo:self]){
        [self removePopUpMenu];
    }
}


-(void)popUpResignKeyWindow:(NSNotification *)notification
{
    if([notification.object isEqualTo:self.popWindow]){
        [self removePopUpMenu];
    }
}


-(void)mouseDown:(NSEvent *)theEvent
{
    if (!self.enabled) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(popupViewWillPopup:)])
        [self.delegate popupViewWillPopup:self];
    
    
    NSView *popUpView = [self popUpMenuController].view;
    NSWindow *popupWindow = [self getPopWindow:popUpView.frame];
    [popupWindow.contentView addConstrainsToSubview:popUpView leadingSpace:0 trailingSpace:0 topSpace:0 bottomSpace:0];
    
    
    NSRect rect = self.frame;
    rect.origin.y = rect.origin.y - popupWindow.frame.size.height;
    rect.size.height = popupWindow.frame.size.height;
    rect = [self.superview convertRect:rect toView:nil];
    NSRect screenRect = [self.window convertRectToScreen:rect];
    [popupWindow setFrameOrigin:screenRect.origin];
    popupWindow.isVisible = YES;
    [popupWindow makeKeyAndOrderFront:self];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AMPopUpWillShowNotification object:self];
}


-(NSString*)stringValue
{
     return _title;
}

-(AMPopUpMenuController*)popUpMenuController
{
    if (_popUpMenuController == nil) {
        _popUpMenuController = [[AMPopUpMenuController alloc] init];
        _popUpMenuController.view = [[NSView alloc] init];
        _popUpMenuController.delegate = self;
    }
    
    return _popUpMenuController;
}

-(void)itemSelected:(AMPopUpMenuItem *)item
{
    NSString* oldTitle = _title;
    _title = item.title;
    self.indexOfSelectedItem = item.index;
    [self removePopUpMenu];
    [self setNeedsDisplay:YES];
    
    if (self.delegate && [oldTitle isNotEqualTo:_title]) {
        [self.delegate itemSelected:self];
    }
}

-(CGFloat)popupItemHeight
{
    return self.bounds.size.height;
}

-(CGFloat)popupItemWidth
{
    return self.bounds.size.width;
}

-(void)addItemWithTitle:(NSString*)title
{
    [[self popUpMenuController] addItemWithTitle: title];
}


-(void)insertItemWithTitle:(NSString*)title atIndex:(NSInteger)index
{
    [[self popUpMenuController] insertItemWithTitle:title atIndex:index];
}


-(void)removeAllItems
{
    _title = @"";
    [[self popUpMenuController] removeAllItems];
    _popUpMenuController = nil;
}


-(void)addItemsWithTitles:(NSArray*)titles
{
    [[self popUpMenuController] addItemsWithTitles: titles];
}


-(BOOL)resignFirstResponder
{
    [self removePopUpMenu];
    return YES;
}

-(void)removePopUpMenu
{
    self.popWindow.isVisible = NO;
}


-(void)mouseEntered:(NSEvent *)theEvent
{
    self.mouseEntered = YES;
    [self setNeedsDisplay:YES];
}

-(void)mouseExited:(NSEvent *)theEvent
{
    self.mouseEntered = NO;
    [self setNeedsDisplay:YES];
}

-(BOOL)acceptsFirstResponder
{
    return  YES;
}

-(void)selectItemAtIndex:(NSUInteger)index
{
    [[self popUpMenuController] selectItemAtInedex:index];
}

-(void)selectItemWithTitle:(NSString*)title
{
    [[self popUpMenuController] selectItemWithTitle:title];
}


-(NSUInteger)itemCount
{
    return [[self popUpMenuController] itemCount];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
