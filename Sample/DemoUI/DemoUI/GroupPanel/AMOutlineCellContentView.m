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

@property NSImageView *iconView1;
@property NSImageView *iconView2;
@property NSImageView *iconView3;
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
        
        //Add btn1,
        trailing = 25*2;
        _btn1 = [[NSButton alloc] initWithFrame:tempRect];
        _btn1.image = [NSImage imageNamed:@"NSActionTemplate"];
        
        [self addConstrainsToFixSizeSubview:_btn1
                                      width:width
                              trailingSpace:trailing
                                     height:heigh
                                bottomSpace:bottom];
        
        //Add Icon3,
        trailing = 25*3;
        _iconView3 = [[NSImageView alloc] initWithFrame:tempRect];
        _iconView3.imageAlignment = NSImageAlignCenter;
        _iconView3.image = [NSImage imageNamed:@"NSActionTemplate"];
        
        [self addConstrainsToFixSizeSubview:_iconView3
                                      width:width
                              trailingSpace:trailing
                                     height:heigh
                                bottomSpace:bottom];
        
        //Add Icon2,
        trailing = 25*4;
        _iconView2 = [[NSImageView alloc] initWithFrame:tempRect];
        _iconView2.imageAlignment = NSImageAlignCenter;
        _iconView2.image = [NSImage imageNamed:@"NSActionTemplate"];
        
        [self addConstrainsToFixSizeSubview:_iconView2
                                      width:width
                              trailingSpace:trailing
                                     height:heigh
                                bottomSpace:bottom];
        
        
        //Add Icon1,
        trailing = 25*5;
        _iconView1 = [[NSImageView alloc] initWithFrame:tempRect];
        _iconView1.imageAlignment = NSImageAlignCenter;
        _iconView1.image = [NSImage imageNamed:@"NSActionTemplate"];
        [self addConstrainsToFixSizeSubview:_iconView1
                                      width:width
                              trailingSpace:trailing
                                     height:heigh
                                bottomSpace:bottom];
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
