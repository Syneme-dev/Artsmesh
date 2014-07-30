//
//  AMPopUpView.m
//  MyPopUpTest
//
//  Created by 王 为 on 7/31/14.
//  Copyright (c) 2014 王 为. All rights reserved.
//

#import "AMPopUpView.h"
#import "AMPopUpMenuController.h"

@interface AMPopUpView()<AMPopUpMenuDelegate>

@property BOOL mouseEntered;

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
//        self.backgroupColor = [NSColor colorWithCalibratedRed:(51.0f/255.0f) green:(51.0f/255.0f) blue:(51.0f/255.0f) alpha:1];
//        self.mouseOverColor = [NSColor colorWithCalibratedRed:(45.0f/255.0f) green:(45.0f/255.0f)  blue:(45.0f/255.0f)  alpha:1];
        
        self.backgroupColor = [NSColor colorWithCalibratedRed:(38.0f/255.0f)
                                                        green:(38.0f/255.0f)
                                                         blue:(38.0f/255.0f)
                                                        alpha:1];
        self.mouseOverColor = [NSColor colorWithCalibratedRed:(30.0f/255.0f)
                                                        green:(30.0f/255.0f)
                                                         blue:(30.0f/255.0f)
                                                        alpha:1];
        _title = @"";
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
    
    // Drawing code here.
    [NSGraphicsContext saveGraphicsState];
    
    //Drawing background
    
    NSBezierPath* border = [NSBezierPath bezierPathWithRect:self.bounds];
    if (self.mouseEntered) {
        [self.mouseOverColor set];
    }else{
        [self.backgroupColor set];
    }
    
    [border fill];
    
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
    
    NSRect rect = NSMakeRect(contentRect.origin.x + contentRect.size.width - 10 - imageSize, contentRect.origin.y + 5, imageSize, imageSize);
    
    NSImage* triangle = [NSImage imageNamed:@"popUpTriangle"];
    [triangle drawAtPoint:rect.origin fromRect:NSZeroRect operation:NSCompositeHighlight fraction:1.0];
    
    [NSGraphicsContext restoreGraphicsState];
}

-(void)mouseDown:(NSEvent *)theEvent
{
    if (self.popUpMenuController == nil) {
        return;
    }
    
    //CGFloat menuHeight = [self.popUpMenuController menuHeight];
    CGFloat menuHeight = [self popUpMenuController].view.frame.size.height;
    
    NSRect rect = self.frame;
    rect.origin.y = rect.origin.y - menuHeight;
    rect.size.height = menuHeight;

    [self.superview addSubview:[self popUpMenuController].view];
    [self.popUpMenuController.view setFrame:rect];
    [self.superview setNeedsDisplay:YES];
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

-(void)itemSelected:(NSString *)itemTitle
{
    _title = itemTitle;
    [self removePopUpMenu];
    [self setNeedsDisplay:YES];
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
    if (self.popUpMenuController == nil) {
        return;
    }
    
    [self.popUpMenuController.view removeFromSuperview];
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

-(NSUInteger)itemCount
{
    return [[self popUpMenuController] itemCount];
}


@end
