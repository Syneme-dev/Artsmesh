//
//  AMOutlineCellContentView.m
//  DemoUI
//
//  Created by 王为 on 19/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMOutlineCellContentView.h"
#import "NSView_Constrains.h"

@interface AMOutlineCellContentView()

@property NSImageView *iconView0;
@property NSImageView *iconView1;
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
                                   topSpace:top
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
        
        //Add Icon1,
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
        
        
        //Add Icon0,
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
    }
    
    return self;
}


-(void)autoHideBtn:(NSButton *)btn
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
    self.btn0.image = image;
    [self autoHideBtn:self.btn0];
    
    return self.btn0;
}


-(NSButton *)setSecondBtnWithImage:(NSImage *)image
{
    self.btn1.image = image;
    [self autoHideBtn:self.btn1];
    
    return self.btn1;
}


-(NSButton *)setThirdBtnWithImage:(NSImage *)image
{
    self.btn2.image = image;
    [self autoHideBtn:self.btn2];
    
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
    self.iconView0.image = image;
    return self.iconView0;
}


-(NSImageView *)setSecondIconWithImage:(NSImage *)image
{
    self.iconView1.image = image;
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
    
    if ([self.dataSource barColor]) {
        self.barView.image = [AMOutlineCellContentView loadBarByColor:[self.dataSource barColor]];
    }
}


+(NSImage *)loadBarByColor:(NSColor *)color{
    return nil;
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
        [btn setHidden:NO];
    }
}


- (void)mouseExited:(NSEvent *)theEvent
{
    for (NSButton *btn in self.autoHideBtns) {
        [btn setHidden:YES];
    }
}

@end
