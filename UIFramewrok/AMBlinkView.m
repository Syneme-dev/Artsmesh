//
//  AMBlinkView.m
//  UIFramework
//
//  Created by whiskyzed on 3/7/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMBlinkView.h"

@interface AMBlinkView( )
{
    int         _count;
    int         _maxCount;
    float       _interval;
    NSTimer*    _blinkTimer;
    
    NSImage*    _blinkImage;
    NSImage*    _alternateImage;
}
@end

@implementation AMBlinkView
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void) startBlink
{
    [_blinkTimer invalidate];
    _blinkTimer = nil;
    _count      = 0;
    _blinkTimer = [NSTimer scheduledTimerWithTimeInterval:_interval
                                                   target:self
                                                 selector:@selector(onBlinkingTimer:)
                                                 userInfo:nil
                                                  repeats:YES];
}

- (void) stopBlink
{
    [_blinkTimer invalidate];
    _blinkTimer = nil;
    _count = 0;
    
    if ([self.delegate respondsToSelector:@selector(afterStopBlink)])
    {
        [self.delegate afterStopBlink];
    }

}

- (void) onBlinkingTimer:(NSTimer*) timer
{
    _count++;
    
    if(_count >= _maxCount ||
       ([self.delegate respondsToSelector:@selector(shouldStop)] && [self.delegate shouldStop])) {
        [self stopBlink];
    }
    [self blink];
}

- (void) blink
{
    if (_count % 2)
        self.image = _alternateImage;
    else
        self.image = _blinkImage;
    
    [self setNeedsDisplay];
}

- (instancetype) initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect]) {
        [self doInit];
    }
    
    return self;
}

- (void) awakeFromNib
{
    [self doInit];
}

- (void) doInit
{
    _count = 0;
    
    NSImage* image      = [NSImage imageNamed:@"synchronizing_icon"];
    NSImage* alterImage = [NSImage imageNamed:@"user_unmeshed_icon"];
    [self setBlinkImage:image  alternateImage:alterImage];
    [self setBlinkMaxCount:5 timerInterval:0.2];
}


- (BOOL) setBlinkMaxCount : (int)   maxCount
          timerInterval   : (float) interval
{
    if (maxCount <= 1 || interval < 0.1) {
        return NO;
    }
    
    _maxCount  = maxCount;
    _interval  = interval;
    return YES;
}

- (BOOL) setBlinkImage:(NSImage *)image
        alternateImage:(NSImage *)alterImage
{
    if (image == nil || alterImage == nil) {
        return NO;
    }
    
    _blinkImage     = image;
    _alternateImage = alterImage;
    return YES;
}

@end
