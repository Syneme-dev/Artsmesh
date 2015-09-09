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
    BOOL isPressing;
    NSInteger cur_state;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        isHovering = NO;
        isPressing = NO;
        self.states = [[NSArray alloc] initWithObjects:@"disabled", @"active", @"pressed", @"confirm", @"success", @"fail", nil];
        cur_state = 1; // Set initially to Active state
        
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

-(void) updateButtonColors {
    NSColor *currentButtonBackground = self.buttonVC.contentView.backgroundColor;
    NSColor *defaultColor = [self.currentTheme.themeColors objectForKey:@"background"];
    NSColor *hoverColor = [self.currentTheme.themeColors objectForKey:@"hoverDefault"];
    NSColor *lightGrey = [self.currentTheme.themeColors objectForKey:@"textDefault"];
    NSColor *currentTextColor = lightGrey;
    
    if (isHovering && !isPressing) {
        switch (cur_state) {
            case 0: //disabled
                break;
            case 1: //active
                currentTextColor = lightGrey;
                currentButtonBackground = hoverColor;
                break;
            case 2: //pressed
                break;
            default:
                break;
        }
    } else {
        currentButtonBackground = defaultColor;
        currentTextColor = lightGrey;
        
        switch (cur_state) {
            case 0: //disabled
                break;
            case 1: //active
                currentTextColor = lightGrey;
                currentButtonBackground = defaultColor;
                break;
            case 2: //pressed
                currentTextColor = defaultColor;
                currentButtonBackground = lightGrey;
                break;
            default:
                currentButtonBackground = defaultColor;
                break;
        }
    }
    [self.buttonVC.buttonTitleTextField setTextColor:currentTextColor];
    [self.buttonVC.contentView changeBackgroundColor:currentButtonBackground];
    [self.buttonVC.contentView setNeedsDisplay:YES];
}


// Events
- (void)mouseEntered:(NSEvent *)theEvent {
    // Mouse has entered button bounds
    isHovering = YES;
    
    [self updateButtonColors];
    [[NSCursor pointingHandCursor] set];
}

- (void)mouseMoved:(NSEvent *)theEvent {
    // Mouse has moved inside of button bounds
    isHovering = YES;
    
    [self updateButtonColors];
    [[NSCursor pointingHandCursor] set];
}

- (void)mouseExited:(NSEvent *)theEvent {
    // Mouse has exited button bounds
    isHovering = NO;
    
    [self updateButtonColors];
    [[NSCursor arrowCursor] set];
}

- (void)mouseDown:(NSEvent *)theEvent {
    // Mouse has been pressed down
    isPressing = YES;
    
    switch (cur_state) {
        case 0:
            // disabled
            break;
        case 1:
            // active
            [self changeState:@"pressed"];
            break;
        case 2:
            // pressed
            break;
        case 3:
            // confirm
            break;
        case 4:
            // success
            break;
        case 5:
            // fail
            break;
        default:
            break;
    }
}

- (void)mouseUp:(NSEvent *)theEvent {
    // Mouse has been released
    isPressing = NO;
    
    switch (cur_state) {
        case 0:
            // disabled
            break;
        case 1:
            // active
            break;
        case 2:
            // pressed
            [self changeState:@"active"];
            break;
        case 3:
            // confirm
            break;
        case 4:
            // success
            break;
        case 5:
            // fail
            break;
        default:
            break;
    }
}

// Custom functions
- (void)changeState:(NSString *)theState {
    // Changes the current state of the button
    int new_state = 1;
    
    for (NSString *state in self.states) {
        if ([state isEqualToString:theState]) {
            new_state = (int) [self.states indexOfObject:state];
        }
    }
    
    cur_state = new_state;
    
    [self updateBtn:self];
}

- (void)updateBtn:(AMStatesBorderButton *)theBtn {
    // updates the look of the button based on changes in state
    [self updateButtonColors];
}

@end
