//
//  AMStatesBorderButton.m
//  UIFramework
//
//  Created by Brad Phillips on 9/5/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMStandardButton.h"

@implementation AMStandardButton {
    NSInteger cur_state;
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.isHovering = NO;
        self.isPressing = NO;
        self.states = [[NSArray alloc] initWithObjects:@"disabled", @"active", @"pressed", @"confirm", @"success", @"fail", nil];
        cur_state = 1; // Set initially to Active state
        
        self.currentTheme = [[AMTheme alloc] init];
        
        self.buttonVC = [[AMStandardButtonViewController alloc] initWithNibName:@"AMStatesBorderButtonViewController" bundle:nil];
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
    
    [self.currentTheme.colorText setFill];
    NSRectFill(dirtyRect);
    
    [super drawRect:dirtyRect];
}

- (void)setButtonTitle:(NSString *)buttonTitle {
    
    NSFont *themeFont = self.currentTheme.fontStandard;
    NSColor *fontColor = self.currentTheme.colorText;
    
    [self.buttonVC.buttonTitleTextField setStringValue:buttonTitle];
    [self.buttonVC.buttonTitleTextField setFont:themeFont];
    [self.buttonVC.buttonTitleTextField setTextColor:fontColor];
    
    [self setNeedsDisplay:true];
}

-(void) updateButtonColors {
    
    NSColor *currentButtonBackground = self.buttonVC.contentView.backgroundColor;
    NSColor *defaultColor = self.currentTheme.colorBackground;
    NSColor *hoverColor = self.currentTheme.colorBackgroundHover;
    NSColor *lightGrey = self.currentTheme.colorText;
    NSColor *currentTextColor = lightGrey;
    
    
    if (self.isHovering && !self.isPressing) {
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
    self.isHovering = YES;
    
    [self updateButtonColors];
    [[NSCursor pointingHandCursor] set];
}

- (void)mouseMoved:(NSEvent *)theEvent {
    // Mouse has moved inside of button bounds
    self.isHovering = YES;
    
    [self updateButtonColors];
    [[NSCursor pointingHandCursor] set];
}

- (void)mouseExited:(NSEvent *)theEvent {
    // Mouse has exited button bounds
    self.isHovering = NO;
    
    [self updateButtonColors];
    [[NSCursor arrowCursor] set];
}

- (void)mouseDown:(NSEvent *)theEvent {
    // Mouse has been pressed down
    self.isPressing = YES;
    self.triggerPressed = NO;
    
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
    
    [super mouseDown:theEvent];
}

- (void)mouseUp:(NSEvent *)theEvent {
    NSLog(@"mouse up on button");
    // Mouse has been released
    self.isPressing = NO;
    self.triggerPressed = YES;
    
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
    
    [super mouseUp:theEvent];
    
    self.triggerPressed = NO;
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

- (void)updateBtn:(AMStandardButton *)theBtn {
    // updates the look of the button based on changes in state
    [self updateButtonColors];
}

@end
