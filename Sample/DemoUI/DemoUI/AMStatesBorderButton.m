//
//  AMStatesBorderButton.m
//  UIFramework
//
//  Created by Brad Phillips on 9/5/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMStatesBorderButton.h"

@implementation AMStatesBorderButton {
    BOOL isHovering;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        isHovering = NO;
        
        self.currentTheme = [[AMTheme alloc] init];
        
        self.buttonVC = [[AMStatesBorderButtonViewController alloc] initWithNibName:@"AMStatesBorderButtonViewController" bundle:nil];
        NSView *vcView = [self.buttonVC view];
        
        [self setAutoresizesSubviews:TRUE];
        vcView.autoresizingMask = NSViewWidthSizable |  NSViewHeightSizable;
        
        NSSize newSize = NSMakeSize(self.frame.size.width, self.frame.size.height);
        
        [vcView setFrameSize:newSize];
        
        [self addSubview:vcView];
        
        //Set up cursor tracking for button mimic
        NSCursor *currentCursor = [NSCursor currentCursor];
        
        NSTrackingArea *trackingArea = [[NSTrackingArea alloc] initWithRect: [self bounds]
            options: (NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveAlways )
            owner:self userInfo:nil];
        
        [self addTrackingArea:trackingArea];
        [self addCursorRect:[self bounds] cursor:currentCursor];
        [currentCursor setOnMouseEntered:YES];
    
    }
    
    return self;
}


- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here
    
    [[self.currentTheme.themeColors objectForKey:@"textDefault"] setFill];
    NSRectFill(dirtyRect);
    
    [super drawRect:dirtyRect];
}

- (void)setButtonTitle:(NSString *)buttonTitle {
    NSFont *themeFont = [self.currentTheme.themeFonts objectForKey:@"standard"];
    NSColor *fontColor = [self.currentTheme.themeColors objectForKey:@"textDefault"];
    
    [self.buttonVC.buttonTitleTextField setStringValue:buttonTitle];
    [self.buttonVC.buttonTitleTextField setFont:themeFont];
    [self.buttonVC.buttonTitleTextField setTextColor:fontColor];
    
    [self setNeedsDisplay:true];
}

-(void) updateButtonBackgroundColor {
    NSColor *currentButtonBackground = self.buttonVC.contentView.backgroundColor;
    NSColor *defaultColor = [self.currentTheme.themeColors objectForKey:@"background"];
    NSColor *hoverColor = [self.currentTheme.themeColors objectForKey:@"hoverDefault"];
    if (isHovering) {
        if ([currentButtonBackground isEqual:[self.currentTheme.themeColors objectForKey:@"background"]]) {
            currentButtonBackground = hoverColor;
            [self.buttonVC.contentView changeBackgroundColor:hoverColor];
            [self.buttonVC.contentView setNeedsDisplay:YES];
        } else {
            return;
        }
    } else {
        currentButtonBackground = defaultColor;
        [self.buttonVC.contentView changeBackgroundColor:defaultColor];
        [self.buttonVC.contentView setNeedsDisplay:YES];
    }
}


// Events
- (void)mouseEntered:(NSEvent *)theEvent {
    // Mouse has entered button bounds
    isHovering = YES;
    
    [self updateButtonBackgroundColor];
    [[NSCursor pointingHandCursor] set];
}

- (void)mouseMoved:(NSEvent *)theEvent {
    // Mouse has moved inside of button bounds
    isHovering = YES;
    
    [self updateButtonBackgroundColor];
    [[NSCursor pointingHandCursor] set];
}

- (void)mouseExited:(NSEvent *)theEvent {
    // Mouse has exited button bounds
    isHovering = NO;
    
    [self updateButtonBackgroundColor];
    [[NSCursor arrowCursor] set];
}

@end
