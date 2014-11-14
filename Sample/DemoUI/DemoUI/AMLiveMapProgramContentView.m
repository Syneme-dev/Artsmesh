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
                  [fontManager fontWithFamily:@"FoundryMonoline" traits:NSItalicFontMask weight:8 size:14.0], @"body-italic",
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
    
    //NSMutableArray *views = [[NSArray alloc] init];
    
    
    self.theScrollView = scrollView;
    
    NSString *theString = theGroup.groupName;
    NSDictionary* theFontAttr = @{NSForegroundColorAttributeName: [NSColor whiteColor], NSFontAttributeName:[self.fonts objectForKeyedSubscript:@"header"]};
    
    NSMutableAttributedString* theAttrString = [[NSMutableAttributedString alloc] initWithString:theString attributes:theFontAttr];
    
    AMLiveMapProgramPanelTextView *theTextView = [[AMLiveMapProgramPanelTextView alloc] init];
    
    [[theTextView textStorage] setAttributedString:theAttrString];
    
    NSSize textViewRect = [theTextView intrinsicContentSize];
    
    NSLog(@"used rect for added text view is: %f, %f", textViewRect.width, textViewRect.height);
    
    [theTextView setFrameSize:textViewRect];
    
    [self addSubview:theTextView];
    
    
    
    
    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSArray *horizontalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subView]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:@{@"subView" : theTextView}];
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subView]|"
                                                                             options:0
                                                                             metrics:nil
                                                                               views:@{@"subView" : theTextView}];
    [self.superview addConstraints:horizontalConstraints];
    [self.superview addConstraints:verticalConstraints];
    
    [self.superview setAutoresizesSubviews:YES];
    
    //[self setFrameSize:NSMakeSize(self.bounds.size.width, textViewRect.height)];
    //NSLog(@"content view frame size is: %f, %f", self.frame.size.width, self.frame.size.height);
    
    //NSSize contentSize = [theTextView intrinsicContentSize];
    //NSLog(@"used rectangle for group name text view is: %f, %f", contentSize.width, contentSize.height);
    
    
    /**
    self.totalH = 0;
    self.theScrollView = scrollView;

    [self fillLiveGroup:theGroup];
    
    for ( AMLiveGroup *subGroup in theGroup.subGroups) {
        [self fillLiveGroup:subGroup];
    }
    **/
    
}

- (void)fillLiveGroup:(AMLiveGroup *)theGroup {
    if (self.theScrollView) {
        [self addTextView:theGroup.groupName toScrollView:self.theScrollView withMargin:0.0 andFont:[self.fonts objectForKeyedSubscript:@"header"]];
        
        [self addTextView:theGroup.description toScrollView:self.theScrollView withMargin:0.0 andFont:[self.fonts objectForKeyedSubscript:@"body-italic"]];
        
        for ( AMLiveUser *theUser in theGroup.users) {
            if ([theUser.fullName length] > 0 && ![theUser.fullName isEqualToString:@"FullName"]){
                [self addTextView:theUser.fullName toScrollView:self.theScrollView withMargin:0.0 andFont:[self.fonts objectForKeyedSubscript:@"body"]];
            } else {
                [self addTextView:theUser.nickName toScrollView:self.theScrollView withMargin:self.indentMargin andFont:[self.fonts objectForKeyedSubscript:@"body"]];
            }
            if ( [theUser.description length] > 0 ) {
                [self addTextView:theUser.description toScrollView:self.theScrollView withMargin:(self.indentMargin) andFont:[self.fonts objectForKeyedSubscript:@"body-italic"]];
            }
            
        }
        
        self.totalH += self.bottomMargin;
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
