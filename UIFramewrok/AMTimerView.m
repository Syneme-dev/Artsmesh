//
//  AMTimerView.m
//  UIFramework
//
//  Created by whiskyzed on 3/12/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMTimerView.h"
#import "AMFoundryFontView.h"
#import "AMUIConst.h"

@interface AMTimerView()
{
    AMFoundryFontView* hour;
    AMFoundryFontView* minute;
    AMFoundryFontView* second;
    AMFoundryFontView* firstColon;
    AMFoundryFontView* secColon;
}

@end

@implementation AMTimerView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (id) initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect]) {
        [self initTimeArea];
    }
    return self;
}

/*
 init Time UI presence.
 |margin 00:00:00 margin|
 magin = 1/10 width, the witdh of '0' is equal to ':'
 so '00' is 1/5 width
 
 */
- (void) initTimeArea
{
    NSRect bounds  = [self bounds];
    int     width  = bounds.size.width;
    int     height = bounds.size.height;
    
    hour  = [[AMFoundryFontView alloc]
             initWithFrame:NSMakeRect(width/10, 0, width/5, height)];
    [hour setStringValue:@"00"];

    firstColon = [[AMFoundryFontView alloc]
                  initWithFrame:NSMakeRect(width*3/10, 0, width/10, height)];
    [firstColon setStringValue:@":"];
    
    minute  = [[AMFoundryFontView alloc]
             initWithFrame:NSMakeRect(width*2/5, 0, width/5, height)];
    [minute setStringValue:@"00"];
    
    secColon = [[AMFoundryFontView alloc]
                  initWithFrame:NSMakeRect(width*3/5, 0, width/10, height)];
    [secColon setStringValue:@":"];
    
    second  = [[AMFoundryFontView alloc]
               initWithFrame:NSMakeRect(width*7/10, 0, width/5, height)];
    [second setStringValue:@"00"];
    
    [self addSubview:hour];
    [self addSubview:firstColon];
    [self addSubview:minute];
    [self addSubview:secColon];
    [self addSubview:second];
    
    [self setBasicFoundryStyle:hour];
    [self setBasicFoundryStyle:firstColon];
    [self setBasicFoundryStyle:minute];
    [self setBasicFoundryStyle:secColon];
    [self setBasicFoundryStyle:second];
}

- (void) setBasicFoundryStyle : (AMFoundryFontView*) foundryFont
{
    [foundryFont setLineBreakMode:NSLineBreakByClipping];
    [foundryFont setAlignment:NSCenterTextAlignment];
    [foundryFont setBordered:NO];
    [foundryFont setTextColor:UI_Color_b7b7b7];
    [foundryFont setDrawsBackground:NO];
    [foundryFont setFontSize:28];

}

@end
