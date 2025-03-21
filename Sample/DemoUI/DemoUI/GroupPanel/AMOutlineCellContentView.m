//
//  AMOutlineCellContentView.m
//  DemoUI
//
//  Created by 王为 on 19/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMOutlineCellContentView.h"
#import "UIFramework/NSView_Constrains.h"

@interface AMOutlineCellContentView()

@property NSImageView *iconView0;
@property NSImageView *iconView1;
@property NSImageView *iconView2;
@property NSButton *btn0;
@property NSButton *btn1;
@property NSButton *btn2;
@property NSMutableArray *autoHideBtns;

@end

@implementation AMOutlineCellContentView


-(instancetype)initWithFrame:(NSRect)frameRect
{
    if(self = [super initWithFrame:frameRect]){
        NSTrackingArea* trackArea = [[NSTrackingArea alloc]
                                     initWithRect:frameRect
                                     options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow )
                                     owner:self
                                     userInfo:nil];
        [self addTrackingArea:trackArea];
        
        //Add bar icon;
        CGFloat top = (frameRect.size.height - 20) / 2;
        CGFloat bottom = top;
        CGFloat leading = 5;
        CGFloat heigh = 20;
        CGFloat width = 20;
        
        NSRect tempRect = NSMakeRect(0, 0, 1, 1);
        _barView = [[NSImageView alloc] initWithFrame:tempRect];
        _barView.imageAlignment = NSImageAlignCenter;
        _barView.image = [NSImage imageNamed:@"NSActionTemplate"];
        
        [self addConstrainsToFixSizeSubview:_barView
                               leadingSpace:leading
                                      width:width
                                   topSpace:top + 3
                                     height:heigh];
        
        
        //AddTitleField
        leading = 25;
        CGFloat trailing = 160;
        
        _titleField = [[AMFoundryFontView alloc] initWithFrame:tempRect];
        _titleField.bordered = NO;
        _titleField.stringValue = @"title";
        _titleField.editable = NO;
        _titleField.drawsBackground = NO;
        _titleField.textColor = [NSColor grayColor];
        [_titleField setFontSize:14];
        //_titleField setAlignment:<#(NSTextAlignment)#>
        
        [self addConstrainsToSubview:_titleField
                        leadingSpace:leading
                       trailingSpace:trailing
                            topSpace:top
                         bottomSpace:bottom];
        
        
        //AddBtn2
        width = 20;
        heigh = 20;
        trailing = 25;
        _btn2 = [[NSButton alloc] initWithFrame:tempRect];
        _btn2.image = [NSImage imageNamed:@"NSActionTemplate"];
        
        [self addConstrainsToFixSizeSubview:_btn2
                                      width:width
                              trailingSpace:trailing
                                     height:heigh
                                bottomSpace:bottom];
        
        [_btn2 setHidden:YES];
        [_btn2 setBordered:NO];
        
        
        //Add btn1,
        trailing = 25*2;
        _btn1 = [[NSButton alloc] initWithFrame:tempRect];
        _btn1.image = [NSImage imageNamed:@"NSActionTemplate"];
        
        [self addConstrainsToFixSizeSubview:_btn1
                                      width:width
                              trailingSpace:trailing
                                     height:heigh
                                bottomSpace:bottom];
        [_btn1 setHidden:YES];
        [_btn1 setBordered:NO];
        
        //Add Btn0,
        trailing = 25*3;
        _btn0 = [[NSButton alloc] initWithFrame:tempRect];
        _btn0.image = [NSImage imageNamed:@"NSActionTemplate"];
        
        [self addConstrainsToFixSizeSubview:_btn0
                                      width:width
                              trailingSpace:trailing
                                     height:heigh
                                bottomSpace:bottom];
        [_btn0 setHidden:YES];
        [_btn0 setBordered:NO];
        
        //Add third left one .
        trailing = 25*4;
        _iconView1 = [[NSImageView alloc] initWithFrame:tempRect];
        _iconView1.imageAlignment = NSImageAlignCenter;
        _iconView1.image = [NSImage imageNamed:@"NSActionTemplate"];
        
        [self addConstrainsToFixSizeSubview:_iconView1
                                      width:width
                              trailingSpace:trailing
                                     height:heigh
                                bottomSpace:bottom];
        
        [_iconView1 setHidden:YES];
        
        
        //Add second left one.
        trailing = 25*5;
        _iconView0 = [[NSImageView alloc] initWithFrame:tempRect];
        _iconView0.imageAlignment = NSImageAlignCenter;
        _iconView0.image = [NSImage imageNamed:@"NSActionTemplate"];
        [self addConstrainsToFixSizeSubview:_iconView0
                                      width:width
                              trailingSpace:trailing
                                     height:heigh
                                bottomSpace:bottom];
        
        [_iconView0 setHidden:YES];
        
        //Add the first left one.
        trailing = 25*6;
        _iconView2 = [[NSImageView alloc] initWithFrame:tempRect];
        _iconView2.imageAlignment = NSImageAlignCenter;
        _iconView2.image = [NSImage imageNamed:@"NSActionTemplate"];
        [self addConstrainsToFixSizeSubview:_iconView2
                                      width:width
                              trailingSpace:trailing
                                     height:heigh
                                bottomSpace:bottom];
        
        [_iconView2 setHidden:YES];
        
    }
    
    return self;
}


-(void)addAutoHideBtn:(NSButton *)btn
{
    if (btn) {
        if (self.autoHideBtns == nil) {
            self.autoHideBtns = [[NSMutableArray alloc] init];
        }
        
        [self.autoHideBtns addObject:btn];
    }
}


-(void)removeAutoHideBtn:(NSButton *)btn
{
    [self.autoHideBtns removeObject:btn];
}


-(NSButton *)setFirstBtnWithImage:(NSImage *)image
{
    NSImage *btnImage = [self resizeImage:image size:NSMakeSize(20, 20)];
    self.btn0.image = btnImage;
    [self addAutoHideBtn:self.btn0];
    
    return self.btn0;
}


-(NSButton *)setSecondBtnWithImage:(NSImage *)image
{
    NSImage *btnImage = [self resizeImage:image size:NSMakeSize(20, 20)];
    self.btn1.image = btnImage;
    [self addAutoHideBtn:self.btn1];
    
    return self.btn1;
}


-(NSButton *)setThirdBtnWithImage:(NSImage *)image
{
    NSImage *btnImage = [self resizeImage:image size:NSMakeSize(20, 20)];
    self.btn2.image = btnImage;
    [self addAutoHideBtn:self.btn2];
    
    return self.btn2;
}


-(void)removeBtnAtPos:(int)pos
{
    switch (pos) {
        case 0:
            self.btn0.image = [NSImage imageNamed:@"NSActionTemplate"];
            [self.btn0 setHidden:YES];
            break;
        case 1:
            self.btn1.image = [NSImage imageNamed:@"NSActionTemplate"];
            [self.btn1 setHidden:YES];
            break;
        case 2:
            self.btn2.image = [NSImage imageNamed:@"NSActionTemplate"];
            [self.btn2 setHidden:YES];
            break;
        default:
            break;
    }
}


-(NSImageView *)setFirstIconWithImage:(NSImage *)image
{
    NSImage *iconImage = [self resizeImage:image size:NSMakeSize(20, 20)];
    self.iconView2.image = iconImage;
    return self.iconView2;
}


-(NSImageView *)setSecondIconWithImage:(NSImage *)image
{
    NSImage *iconImage = [self resizeImage:image size:NSMakeSize(20, 20)];
    self.iconView0.image = iconImage;
    return self.iconView0;
}

-(NSImageView *)setThirdIconWithImage:(NSImage *)image
{
    NSImage *iconImage = [self resizeImage:image size:NSMakeSize(20, 20)];
    self.iconView1.image = iconImage;
    return self.iconView1;
}


-(void)removeIconAtPos:(int)pos
{
    switch (pos) {
        case 0:
            self.iconView0.image = [NSImage imageNamed:@"NSActionTemplate"];
            [self.iconView0 setHidden:YES];
            break;
        case 1:
            self.iconView1.image = [NSImage imageNamed:@"NSActionTemplate"];
            [self.iconView1 setHidden:YES];
            break;
        default:
            break;
    }
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}


-(void)updateUI
{
//    NSBezierPath *path = [NSBezierPath bezierPathWithRect:self.bounds];
//    [[NSColor redColor] setFill];
//    [path fill];
    
    // Drawing code here.
    if ([self.dataSource hideBar]) {
        [self.barView setHidden:YES];
    }else{
        [self.barView setHidden:NO];
    }
    
    if ([self.dataSource title]) {
        self.titleField.stringValue = [self.dataSource title];
    }
    
    if ([self.dataSource barImage]) {
        self.barView.image = [self.dataSource barImage];
    }
}

-(void)setFrame:(NSRect)frame
{
    [super setFrame:frame];
    
    for (NSTrackingArea *area in self.trackingAreas) {
        [self removeTrackingArea:area];
    }
    
    NSTrackingArea* trackArea = [[NSTrackingArea alloc]
                                 initWithRect:frame
                                 options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow )
                                 owner:self
                                 userInfo:nil];
    [self addTrackingArea:trackArea];
    
}

- (NSImage*) resizeImage:(NSImage*)sourceImage size:(NSSize)size
{
    
    NSRect targetFrame = NSMakeRect(0, 0, size.width, size.height);
    NSImage* targetImage = nil;
    NSImageRep *sourceImageRep =
    [sourceImage bestRepresentationForRect:targetFrame
                                   context:nil
                                     hints:nil];
    
    targetImage = [[NSImage alloc] initWithSize:size];
    
    [targetImage lockFocus];
    [sourceImageRep drawInRect: targetFrame];
    [targetImage unlockFocus];
    
    return targetImage;
}


#pragma mark Double Click
- (void)mouseUp:(NSEvent *)event
{
    NSInteger clickCount = [event clickCount];
    if (2 == clickCount) {
        [self handleDoubleClickEvent:event];
    }
}


-(void)handleDoubleClickEvent:(NSEvent *)event
{
    if ([self.delegate respondsToSelector:@selector(doubleClickOnCellContentView:)]) {
        [self.delegate doubleClickOnCellContentView:self];
    }
}


#pragma mark  Tracking Area
- (void)mouseEntered:(NSEvent *)theEvent
{
    for (NSButton *btn in self.autoHideBtns) {
        
        if (btn.enabled) {
            [btn setHidden:NO];
        }
    }
}


- (void)mouseExited:(NSEvent *)theEvent
{
    for (NSButton *btn in self.autoHideBtns) {
        [btn setHidden:YES];
    }
}

@end
