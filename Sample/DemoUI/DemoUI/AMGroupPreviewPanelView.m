//
//  AMGroupPreviewPanelView.m
//  DemoUI
//
//  Created by Brad Phillips on 11/7/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMGroupPreviewPanelView.h"

#define UI_Color_gray [NSColor colorWithCalibratedRed:0.152 green:0.152 blue:0.152 alpha:1]
#define UI_Text_Color_Gray [NSColor colorWithCalibratedRed:(152/255.0f) green:(152/255.0f) blue:(152/255.0f) alpha:1]

@implementation AMGroupPreviewPanelView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UI_Color_gray;
        
        NSShadow *dropShadow = [[NSShadow alloc] init];
        [dropShadow setShadowColor:colorFromRGB(0, 0, 0, 0.5)];
        [dropShadow setShadowOffset:NSMakeSize(0, -4.0)];
        [dropShadow setShadowBlurRadius:4.0];
        [self setShadow:dropShadow];
        
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [self.backgroundColor set];
    [NSBezierPath fillRect:self.bounds];
}

static NSColor *colorFromRGB(unsigned char r, unsigned char g, unsigned char b, float a)
{
    return [NSColor colorWithCalibratedRed:(r/255.0f) green:(g/255.0f) blue:(b/255.0f) alpha:a];
}

-(void)setDescription:(AMLiveGroup *)theGroup {
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    
    NSFont* textFieldFont =  [fontManager fontWithFamily:@"FoundryMonoline" traits:NSUnitalicFontMask weight:5 size:12.0];
    NSDictionary* attr = @{NSForegroundColorAttributeName:UI_Text_Color_Gray, NSFontAttributeName:textFieldFont};
    NSMutableAttributedString* groupDesc = [[NSMutableAttributedString alloc] initWithString:theGroup.description attributes:attr];
    
    NSTextView *newTextView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, self.groupPreviewPanelController.descScrollView.bounds.size.width, 1000)];
    
    [[newTextView textStorage] setAttributedString:groupDesc];
    newTextView.drawsBackground = NO;
    [self.groupPreviewPanelController.descScrollView setDocumentView:newTextView];
}

@end
