//
//  AMAudioMeter.m
//  AMCollectionViewTest
//
//  Created by wangwei on 26/11/14.
//  Copyright (c) 2014 wangwei. All rights reserved.
//

#import "AMAudioMeter.h"

@implementation AMAudioMeter
{
    float _value;
    NSRange _valueRange;
    NSTimer *_timer;
}

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
    self.value = 0.0;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                              target:self
                                            selector:@selector(updateUI)
                                            userInfo:nil repeats:YES];
}

-(void)dealloc
{
    [_timer invalidate];
    _timer = nil;
}

-(void)updateUI
{
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    float ratio = self.value / self.valueRange.length;
    int xPos = 0;
    int yPos = 0;
    int width = self.bounds.size.width;
    int height = self.bounds.size.height * ratio;
    
    NSRect rect = NSMakeRect(xPos, yPos, width, height);
    
    [[NSColor whiteColor] set];
    [[NSBezierPath bezierPathWithRect:rect] fill];
}

-(void)setValue:(float)value
{
    [self willChangeValueForKey:@"value"];
    _value = value;
    [self didChangeValueForKey:@"value"];
}

-(float)value{
    return _value;
}

-(void)setValueRange:(NSRange)valueRange
{
    [self willChangeValueForKey:@"valueRange"];
    _valueRange = valueRange;
    [self didChangeValueForKey:@"valueRange"];
    
    [self setNeedsDisplay:YES];
}

-(NSRange)valueRange{
    return _valueRange;
}



@end
