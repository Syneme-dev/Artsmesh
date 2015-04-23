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
    
    NSTimer* _clock;
    BOOL        _hasTheTimeZone;
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
 //       [self initTimeArea];
    }
    return self;
}

/*
 init Time UI presence.
 | margin 00:00:00 margin |
 magin = 1/10 width, the witdh of '0' is equal to ':' with 1/10 width, 
 then so '00' is 1/5 width
*/
- (void) initTimeArea
{
    NSRect bounds  = [self bounds];
    int     width  = bounds.size.width;
    int     height = bounds.size.height;
    
    hour  = [[AMFoundryFontView alloc]
                    initWithFrame:NSMakeRect(width/10,   0, width/5,  height)];
    [hour setStringValue:@"00"];

    firstColon = [[AMFoundryFontView alloc]
                    initWithFrame:NSMakeRect(width*3/10, 0, width/10, height)];
    [firstColon setStringValue:@":"];
    
    minute  = [[AMFoundryFontView alloc]
                    initWithFrame:NSMakeRect(width*2/5,  0, width/5,  height)];
    [minute setStringValue:@"00"];
    
    secColon = [[AMFoundryFontView alloc]
                    initWithFrame:NSMakeRect(width*3/5,  0, width/10, height)];
    [secColon setStringValue:@":"];
    
    second  = [[AMFoundryFontView alloc]
                    initWithFrame:NSMakeRect(width*7/10, 0, width/5,  height)];
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

- (void) initTimeZoneArea
{
    
}

- (void) awakeFromNib
{
    [self initTimeArea];
    [self updateClock:nil];
    [self startTime];
}

- (void) setBasicFoundryStyle : (AMFoundryFontView*) foundryFontView
{
    [foundryFontView setLineBreakMode:NSLineBreakByClipping];
    [foundryFontView setAlignment:NSCenterTextAlignment];
    [foundryFontView setBordered:NO];
    [foundryFontView setTextColor:UI_Color_b7b7b7];
    [foundryFontView setDrawsBackground:NO];
    CGFloat fontSize = [self properFontSize:foundryFontView];
    [foundryFontView setFontSize:fontSize];
}


- (CGFloat) properFontSize : (AMFoundryFontView*) foundryFontView
{
    //@"00"
    if ([foundryFontView stringValue].length == 2) {
        return 28;
    }
    else
        return 28 - 2;
}

- (void) initTimeZone : (NSTimeZone*) zone
{
    if (zone == nil)
        zone = [NSTimeZone systemTimeZone];

    
}

- (void) startTime
{
    NSTimeInterval interval = ((int)[NSDate timeIntervalSinceReferenceDate]) + 1.01;
    NSDate* fireDate = [NSDate dateWithTimeIntervalSinceReferenceDate:interval];
    
    NSTimer *timer = [[NSTimer alloc] initWithFireDate:fireDate
                                              interval:1
                                                target:self
                                              selector:@selector(updateClock:)
                                              userInfo:nil
                                               repeats:YES];
    
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void) updateClock : (NSNotification*) notfication
{
    NSDate*     date = [NSDate date];

    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *timeComps =
            [gregorian components:(NSHourCalendarUnit   | NSMinuteCalendarUnit |
                                   NSSecondCalendarUnit | NSTimeZoneCalendarUnit)
                         fromDate:date];
    
    [hour   setStringValue: [NSString stringWithFormat:@"%02ld",[timeComps hour]]];
    [minute setStringValue: [NSString stringWithFormat:@"%02ld",[timeComps minute]]];
    [second setStringValue: [NSString stringWithFormat:@"%02ld",[timeComps second]]];
    
    if (YES) {
        NSTimeZone* zone = [timeComps timeZone];
        NSLog(@"%@", [zone abbreviationForDate:date]);
    }
}


@end
