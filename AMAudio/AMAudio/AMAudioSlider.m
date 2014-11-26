//
//  AMAudioSlider.m
//  AMCollectionViewTest
//
//  Created by wangwei on 26/11/14.
//  Copyright (c) 2014 wangwei. All rights reserved.
//

#import "AMAudioSlider.h"

#define POLE_WIDTH      10
#define HOLDER_WIDTH    30

@implementation AMAudioSlider

-(instancetype)initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect]) {
        [self doInit];
    }
    
    return self;
}


-(void)awakeFromNib
{
    [self doInit];
}


-(void)doInit
{
    self.valueRange = NSMakeRange(0.0f, 1.0f);
    self.value = 0.5;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    //draw backgroud
//    [[NSColor redColor] set];
//    [[NSBezierPath bezierPathWithRect:self.bounds] fill];
    
    
    //draw pole
    int xPos = (self.bounds.size.width - POLE_WIDTH) / 2;
    int yPos = 0;
    int width = POLE_WIDTH;
    int height = self.bounds.size.height;
    NSRect poleRect = NSMakeRect(xPos, yPos, width, height);
    
    [[NSColor darkGrayColor] set];
    [[NSBezierPath bezierPathWithRect:poleRect] fill];

    //draw holer
    float ratio = self.value / self.valueRange.length;
    xPos = xPos + POLE_WIDTH / 2 - HOLDER_WIDTH / 2;
    yPos = height * ratio - HOLDER_WIDTH / 2;
    width = HOLDER_WIDTH;
    height = HOLDER_WIDTH;
    
    NSRect holderRect = NSMakeRect(xPos, yPos, width, height);
    [[NSBezierPath bezierPathWithRect:holderRect] fill];
    
}

-(void)mouseDown:(NSEvent *)theEvent
{
    NSPoint pt = theEvent.locationInWindow;
    pt = [self convertPoint:pt fromView: nil];
    self.value = pt.y * self.valueRange.length / self.bounds.size.height;
    
    if ([self.delegate respondsToSelector:@selector(slider:ValueChanged:)]) {
        [self.delegate slider:self ValueChanged:self.value];
    }
    
    [self setNeedsDisplay:YES];
}

-(void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint pt = theEvent.locationInWindow;
    pt = [self convertPoint:pt fromView: nil];

    if (pt.y >= self.bounds.size.height || pt.y < 0) {
            //limite the mousr move range
    }
    
    self.value = pt.y * self.valueRange.length / self.bounds.size.height;
    
    if ([self.delegate respondsToSelector:@selector(slider:ValueChanged:)]) {
        [self.delegate slider:self ValueChanged:self.value];
    }
    
    [self setNeedsDisplay:YES];
}

@end
