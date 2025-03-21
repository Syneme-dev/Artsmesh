//
//  AMAudioSlider.m
//  AMCollectionViewTest
//
//  Created by wangwei on 26/11/14.
//  Copyright (c) 2014 wangwei. All rights reserved.
//

#import "AMAudioSlider.h"

#define POLE_WIDTH      5
#define HOLDER_WIDTH    24

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
    
    [[NSColor colorWithCalibratedRed:46.0/255 green:58.0/255 blue:75.0/255 alpha:1] set];
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

    if (pt.y >= self.bounds.size.height){
        pt.y = self.bounds.size.height;
    }else if( pt.y < 0) {
        pt.y = 0;
    }
    
    self.value = pt.y * self.valueRange.length / self.bounds.size.height;
    
    if ([self.delegate respondsToSelector:@selector(slider:ValueChanged:)]) {
        [self.delegate slider:self ValueChanged:self.value];
    }
    
    [self setNeedsDisplay:YES];
}

@end
