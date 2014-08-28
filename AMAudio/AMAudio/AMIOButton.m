//
// AMIOButton.m
//  Connect-the-Dot
//
//  Created by Brad Phillips on 8/15/14.
//  Copyright (c) 2014 Detao. All rights reserved.
//

#import "AMIOButton.h"

@implementation AMIOButton

//@synthesize selected = _selected;
@synthesize connectedTo = _connectedTo;
@synthesize name = _name;
@synthesize butWidth = _butWidth;
@synthesize butHeight = _butHeight;

NSString *IO_BUTTON_NAME=@"io-button-open.png";
NSString *IO_BUTTON_PRESSED_NAME=@"io-button-selected.png";
NSString *IO_BUTTON_CONNECTED_NAME=@"io-button-connected.png";

- (id)initWithFrame:(CGRect)frame andSize:(int) butSize {
    if (self = [super initWithFrame:frame]) {
        // do my additional initialization here
        [self setBordered:NO];
        [self setNeedsDisplay:YES];
        [self setButtonType:NSSwitchButton];
        [self setImage:[NSImage imageNamed:IO_BUTTON_NAME]];
        [self setAlternateImage:[NSImage imageNamed:IO_BUTTON_PRESSED_NAME]];
        [[self image] setSize:NSMakeSize(butSize,butSize)];
        [[self alternateImage] setSize:NSMakeSize(butSize,butSize)];
        self.butWidth = butSize;
        self.butHeight = butSize;
        //self.selected = FALSE;
        self.connectedTo = FALSE;

    }
    return self;
}

- (BOOL) wantsUpdateLayer {
    return YES;
}

- (void) updateLayer {
    
    //If button is pressed
    /**
    if ([self.cell isHighlighted]) {
        self.layer.contents = [NSImage imageNamed:@"io-button-selected.png"];
    } else {
        self.layer.contents = [NSImage imageNamed:@"io-button-open.png"];
    }
     **/
    
}

- (void) resetButton:(AMIOButton *)theButton {
    // This function takes the previously connected button back to it's original state
    NSLog(@"reset button called for button %@", theButton);
    
    if ( theButton.state == NSOnState ) {
        [theButton setState:NSOffState];
    }
    
    [theButton setAlternateImage:[NSImage imageNamed:IO_BUTTON_PRESSED_NAME]];
    
}

- (void) makeButtonConnected:(AMIOButton *)theButton {
    [theButton setAlternateImage:[NSImage imageNamed:IO_BUTTON_CONNECTED_NAME]];
    [[theButton alternateImage] setSize:NSMakeSize(theButton.butWidth,theButton.butHeight)];
}


@end

