//
//  AMLiveMapProgramScrollView.m
//  DemoUI
//
//  Created by Brad Phillips on 11/10/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMLiveMapProgramContentView.h"
#import "AMCoreData/AMCoreData.h"
#import "AMLiveMapProgramPanelTextView.h"

@implementation AMLiveMapProgramContentView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        /**
        NSLog(@"setup running!");
        NSTextField *testString = [[NSTextField alloc] initWithFrame:self.bounds];
        [testString setStringValue:@"test"];
        [self addSubview:testString];
        NSLog(@"test string x/y width/height is: %f/%f, %f/%f", testString.frame.origin.x, testString.frame.origin.y, testString.frame.size.width, testString.frame.size.height);
        **/
        
        NSFontManager *fontManager = [NSFontManager sharedFontManager];
        self.fonts = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                  [fontManager fontWithFamily:@"FoundryMonoline" traits:NSUnitalicFontMask weight:5 size:16.0], @"header",
                  [fontManager fontWithFamily:@"FoundryMonoline" traits:NSUnitalicFontMask weight:8 size:14.0], @"body",
                  [fontManager fontWithFamily:@"FoundryMonoline" traits:NSUnitalicFontMask weight:10 size:13.0], @"13",
                  [fontManager fontWithFamily:@"FoundryMonoline" traits:NSUnitalicFontMask weight:5 size:12.0], @"small",
                  [fontManager fontWithFamily:@"FoundryMonoline" traits:NSItalicFontMask weight:5 size:12.0], @"small-italic",
                  nil];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    
}

- (void)fillContent:(AMLiveGroup *)theGroup inScrollView:(NSScrollView *)scrollView {
    int contentH = 0;
    NSDictionary* bodyFontAttr = @{NSForegroundColorAttributeName: [NSColor whiteColor], NSFontAttributeName:[self.fonts objectForKey:@"body"]};
    
    
    NSMutableAttributedString* groupTitle = [[NSMutableAttributedString alloc] initWithString:theGroup.fullName attributes:bodyFontAttr];
    double groupTitleH = [groupTitle boundingRectWithSize:NSMakeSize(scrollView.bounds.size.width, 0) options:NSStringDrawingUsesDeviceMetrics].size.height;
    contentH += groupTitleH;
    AMLiveMapProgramPanelTextView *groupTitleTextView = [[AMLiveMapProgramPanelTextView alloc] initWithFrame:NSMakeRect(0, 0, scrollView.bounds.size.width, groupTitleH)];
    [[groupTitleTextView textStorage] setAttributedString:groupTitle];
    
    
    [self addSubview:groupTitleTextView];
    
    
    NSMutableAttributedString* groupDesc = [[NSMutableAttributedString alloc] initWithString:theGroup.description attributes:bodyFontAttr];
    double groupDescH = [groupDesc boundingRectWithSize:NSMakeSize(scrollView.bounds.size.width, 0) options:NSStringDrawingUsesDeviceMetrics].size.height;
    contentH += groupDescH;
    AMLiveMapProgramPanelTextView *groupDescTextView = [[AMLiveMapProgramPanelTextView alloc] initWithFrame:NSMakeRect(0, contentH, scrollView.bounds.size.width, groupDescH)];
    [[groupDescTextView textStorage] setAttributedString:groupDesc];
    
    [self addSubview:groupDescTextView];
}

- (BOOL)isFlipped{
    return YES;
}

@end
