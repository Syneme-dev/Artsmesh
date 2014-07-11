//
//  AMGroupPanelDetailView.m
//  DemoUI
//
//  Created by 王 为 on 7/11/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMGroupPanelDetailView.h"

@interface AMGroupPanelDetailView()

@property (strong) NSButton* leftButton;
@property (strong) NSButton* rightButton;

@end

@implementation AMGroupPanelDetailView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)awakeFromNib
{
    NSRect rect = self.bounds;
    NSRect leftRect = NSMakeRect(rect.origin.x, rect.origin.y, rect.size.width / 2 - 1, 35);
    NSRect rightRect = NSMakeRect(rect.origin.x + rect.size.width / 2 + 1, rect.origin.y, rect.size.width / 2 - 1, 35.0);
    
    self.leftButton = [[NSButton alloc] initWithFrame:leftRect];
    self.rightButton = [[NSButton alloc] initWithFrame:rightRect];
    [self addSubview:self.leftButton];
    [self addSubview:self.rightButton];
    
    self.leftButton.title = ([self.leftBtnTitle isEqualTo:@""]) ? @"LeftBtn": self.leftBtnTitle;
    self.rightButton.title = ([self.rightBtnTitle isEqualTo:@""]) ? @"RightBtn": self.rightBtnTitle;
    
    [self.leftButton setButtonType:NSMomentaryLightButton];
    [self.rightButton setButtonType:NSMomentaryLightButton];
    
    [self.leftButton setBordered:NO];
    [self.rightButton setBordered:NO];
    
    [self.leftButton setTarget:self];
    [self.rightButton setTarget:self];

    [self.leftButton setAction:@selector(leftButtonClick)];
    [self.rightButton setAction:@selector(rightButtonClick)];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    NSRect contentR = self.bounds;
    
    [NSGraphicsContext saveGraphicsState];
    
    [[NSColor grayColor] set];
    NSBezierPath *btnLine = [NSBezierPath bezierPath];
    [btnLine moveToPoint:NSMakePoint(contentR.origin.x, contentR.origin.y + 36)];
    [btnLine lineToPoint:NSMakePoint(contentR.origin.x + contentR.size.width, contentR.origin.y + 36)];
    [btnLine moveToPoint:NSMakePoint(contentR.origin.x + contentR.size.width / 2, contentR.origin.y + 36)];
    [btnLine lineToPoint:NSMakePoint(contentR.origin.x + contentR.size.width / 2, contentR.origin.y)];
    [btnLine stroke];
    [NSGraphicsContext restoreGraphicsState];

}

-(void)leftButtonClick
{
    
}

-(void)rightButtonClick
{
    
}


@end
