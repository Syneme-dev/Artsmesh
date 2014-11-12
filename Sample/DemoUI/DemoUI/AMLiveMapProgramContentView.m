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
        self.bottomMargin = 10;
        self.indentMargin = 15;
        
        NSFontManager *fontManager = [NSFontManager sharedFontManager];
        self.fonts = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                  [fontManager fontWithFamily:@"FoundryMonoline" traits:NSUnitalicFontMask weight:8 size:16.0], @"header",
                  [fontManager fontWithFamily:@"FoundryMonoline" traits:NSUnitalicFontMask weight:8 size:14.0], @"body",
                  [fontManager fontWithFamily:@"FoundryMonoline" traits:NSUnitalicFontMask weight:8 size:13.0], @"13",
                  [fontManager fontWithFamily:@"FoundryMonoline" traits:NSUnitalicFontMask weight:8 size:12.0], @"small",
                  [fontManager fontWithFamily:@"FoundryMonoline" traits:NSItalicFontMask weight:8 size:12.0], @"small-italic",
                  nil];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    
}

- (void)fillContent:(AMLiveGroup *)theGroup inScrollView:(NSScrollView *)scrollView {
    self.totalH = 0;
    self.theScrollView = scrollView;

    [self fillLiveGroup:theGroup];
    
    for ( AMLiveGroup *subGroup in theGroup.subGroups) {
        [self fillLiveGroup:subGroup];
    }
}

- (void)fillLiveGroup:(AMLiveGroup *)theGroup {
    if (self.theScrollView) {
        [self addTextView:theGroup.groupName toScrollView:self.theScrollView withMargin:0.0 andFont:[self.fonts objectForKeyedSubscript:@"header"]];
        
        [self addTextView:theGroup.description toScrollView:self.theScrollView withMargin:0.0 andFont:[self.fonts objectForKeyedSubscript:@"body"]];
        
        for ( AMLiveUser *theUser in theGroup.users) {
            if ([theUser.fullName length] > 0 && ![theUser.fullName isEqualToString:@"FullName"]){
                [self addTextView:theUser.fullName toScrollView:self.theScrollView withMargin:0.0 andFont:[self.fonts objectForKeyedSubscript:@"body"]];
            } else {
                [self addTextView:theUser.nickName toScrollView:self.theScrollView withMargin:self.indentMargin andFont:[self.fonts objectForKeyedSubscript:@"body"]];
            }
            if ( [theUser.description length] > 0 ) {
                [self addTextView:theUser.description toScrollView:self.theScrollView withMargin:(self.indentMargin * 2) andFont:[self.fonts objectForKeyedSubscript:@"body"]];
            }
        }
    }
}

- (void)addTextView:(NSString *)theString toScrollView:(NSScrollView *)scrollView withMargin:(double) theMargin andFont:(NSFont *)theFont {
    NSDictionary* bodyFontAttr = @{NSForegroundColorAttributeName: [NSColor whiteColor], NSFontAttributeName:theFont};
    
    NSMutableAttributedString* theAttrString = [[NSMutableAttributedString alloc] initWithString:theString attributes:bodyFontAttr];
    double theStringH = [theAttrString boundingRectWithSize:NSMakeSize(scrollView.bounds.size.width, 0) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading].size.height;
    
    AMLiveMapProgramPanelTextView *theTextView = [[AMLiveMapProgramPanelTextView alloc] initWithFrame:NSMakeRect(0 + theMargin, self.totalH, scrollView.bounds.size.width - theMargin, theStringH)];
    [[theTextView textStorage] setAttributedString:theAttrString];
    
    self.totalH += theStringH;
    self.totalH += self.bottomMargin;

    [self addSubview:theTextView];
    
    [self setFrameSize:NSMakeSize(scrollView.bounds.size.width, self.totalH)];
}

- (BOOL)isFlipped{
    return YES;
}

@end
