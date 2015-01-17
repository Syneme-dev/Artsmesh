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

#define UI_Text_Color_Gray [NSColor colorWithCalibratedRed:(152/255.0f) green:(152/255.0f) blue:(152/255.0f) alpha:1]

@implementation AMLiveMapProgramContentView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.bottomMargin = 10;
        self.indentMargin = 15;
        self.allFields = [[NSMutableArray alloc] init];
                
        //Prep Video Stream Container
        self.liveVideoStream = [[WebView alloc] initWithFrame:NSMakeRect(0, 0, self.frame.size.width, ((3*self.frame.size.width)/4))];
        [self.liveVideoStream setFrameLoadDelegate:self];
        [self.liveVideoStream setDrawsBackground:NO];
        
        NSFontManager *fontManager = [NSFontManager sharedFontManager];
        self.fonts = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                  [fontManager fontWithFamily:@"FoundryMonoline" traits:NSUnitalicFontMask weight:8 size:15.0], @"header",
                  [fontManager fontWithFamily:@"FoundryMonoline" traits:NSUnitalicFontMask weight:8 size:13.0], @"body",
                  [fontManager fontWithFamily:@"FoundryMonoline" traits:NSItalicFontMask weight:8 size:13.0], @"body-italic",
                  [fontManager fontWithFamily:@"FoundryMonoline" traits:NSUnitalicFontMask weight:8 size:12.0], @"13",
                  [fontManager fontWithFamily:@"FoundryMonoline" traits:NSUnitalicFontMask weight:8 size:10.0], @"small",
                  [fontManager fontWithFamily:@"FoundryMonoline" traits:NSItalicFontMask weight:8 size:10.0], @"small-italic",
                  nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowResized:) name:NSWindowDidResizeNotification object:self.window];
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    // Drawing code here.
}

- (void) fakeLiveProgram:(AMLiveGroup *)theGroup {
    theGroup.broadcasting = YES;
    theGroup.broadcastingURL = @"https://www.youtube.com/embed/XxSOcc9qcsI";
    
}

- (void)fillContent:(AMLiveGroup *)theGroup {
    
    //NSMutableArray *views = [[NSArray alloc] init];
    [self.allFields removeAllObjects];

    /**
    NSString *theString = theGroup.groupName;
    NSDictionary* theFontAttr = @{NSForegroundColorAttributeName: UI_Text_Color_Gray, NSFontAttributeName:[self.fonts objectForKeyedSubscript:@"header"]};
    
    NSMutableAttributedString* theAttrString = [[NSMutableAttributedString alloc] initWithString:theString attributes:theFontAttr];
    
    AMLiveMapProgramPanelTextView *theTextView = [[AMLiveMapProgramPanelTextView alloc] init];
    
    [[theTextView textStorage] setAttributedString:theAttrString];
    
    NSSize textViewRect = [theTextView intrinsicContentSize];
    
    NSLog(@"used rect for added text view is: %f, %f", textViewRect.width, textViewRect.height);
    
    [theTextView setFrameSize:textViewRect];
    
    [self addSubview:theTextView];
     **/
    
    self.totalH = 0;
    
    //[self fakeLiveProgram:theGroup];
    if (theGroup.broadcasting && [theGroup.broadcastingURL length] != 0) {
        //Add the Video embed into the program view via webview
        [self addVideoStream:theGroup];
    } else {
        //conditions for video not met..
    }

    [self fillLiveGroup:theGroup];
    
    for ( AMLiveGroup *subGroup in theGroup.subGroups) {
        [self fillLiveGroup:subGroup];
    }
    
    
}

- (void)addVideoStream:(AMLiveGroup *)theGroup {
    if (theGroup.broadcasting && theGroup.broadcastingURL) {
        //Add the Video embed into the program view via webview
        [self.liveVideoStream setFrame:NSMakeRect(0, self.totalH, self.frame.size.width, ((3*self.frame.size.width)/4))];
        [self addSubview:self.liveVideoStream];
        
        NSURL *stream_url = [NSURL URLWithString:
                            [NSString stringWithFormat:@"%@",theGroup.broadcastingURL]];
        [self.liveVideoStream.mainFrame loadRequest:
         [NSURLRequest requestWithURL:stream_url]];
        
        self.totalH += self.liveVideoStream.frame.size.height;
        self.totalH += self.bottomMargin;
        
        // Record the field for later user
        
        NSMutableDictionary *theField = [[NSMutableDictionary alloc] init];
        
        [theField setObject:self.liveVideoStream forKey:@"object"];
        [self.allFields addObject:theField];
    }
}

- (void)fillLiveGroup:(AMLiveGroup *)theGroup {
    if (self.enclosingScrollView) {
        [self addTextView:theGroup.groupName withIndent:0.0 andFont:[self.fonts objectForKeyedSubscript:@"header"]];
        
        [self addTextView:theGroup.description withIndent:0.0 andFont:[self.fonts objectForKeyedSubscript:@"body"]];
        
        for ( AMLiveUser *theUser in theGroup.users) {
            if ([theUser.fullName length] > 0 && ![theUser.fullName isEqualToString:@"FullName"]){
                [self addTextView:theUser.fullName withIndent:self.indentMargin andFont:[self.fonts objectForKeyedSubscript:@"body"]];
            } else {
                [self addTextView:@"Full Name" withIndent:self.indentMargin andFont:[self.fonts objectForKeyedSubscript:@"body"]];
            }
            if ( [theUser.description length] > 0 ) {
                [self addTextView:theUser.description withIndent:(self.indentMargin) andFont:[self.fonts objectForKeyedSubscript:@"body"]];
            }
            
        }
        
        self.totalH += self.bottomMargin;
    }
}

- (void)addTextView:(NSString *)theString withIndent:(double) theIndent andFont:(NSFont *)theFont {
    NSDictionary* theFontAttr = @{NSForegroundColorAttributeName: UI_Text_Color_Gray, NSFontAttributeName:theFont};
    
    NSMutableAttributedString* theAttrString = [[NSMutableAttributedString alloc] initWithString:theString attributes:theFontAttr];
    double theStringH = [theAttrString boundingRectWithSize:NSMakeSize(self.enclosingScrollView.bounds.size.width, 0) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading].size.height;
    
    AMLiveMapProgramPanelTextView *theTextView = [[AMLiveMapProgramPanelTextView alloc] initWithFrame:NSMakeRect(0 + theIndent, self.totalH, self.enclosingScrollView.bounds.size.width - theIndent, theStringH)];
    [[theTextView textStorage] setAttributedString:theAttrString];
    
    self.totalH += theStringH;
    self.totalH += self.bottomMargin;

    [self addSubview:theTextView];
    
    [self setFrameSize:NSMakeSize(self.enclosingScrollView.bounds.size.width, self.totalH)];
    
    
    // Record the field for later user
    
    NSMutableDictionary *theField = [[NSMutableDictionary alloc] init];
    
    [theField setObject:theTextView forKey:@"object"];
    [theField setObject:theFontAttr forKey:@"theFontAttr"];
    [theField setObject:[NSNumber numberWithDouble:theIndent] forKey:@"indent"];
    
    
    [self.allFields addObject:theField];
}

- (void)windowResized: (NSNotification *)notification {
    
    [self updateDocumentView];
}

- (void) updateDocumentView {
    
    if ( !NSEqualRects(self.enclosingScrollView.bounds, self.curSize) ) {
        // Size has changed, update document view..
        self.totalH = 0;
        
        [self resetDocumentSize:NSMakeSize(self.enclosingScrollView.bounds.size.width, 0)];
        
        for (NSMutableDictionary *curObject in self.allFields) {
            
            NSObject *theObject = [curObject objectForKey:@"object"];
            
            if ( [theObject isKindOfClass:[AMLiveMapProgramPanelTextView class]] ) {
                // current object is a flex text view, resize accordingly
    
                AMLiveMapProgramPanelTextView *theTextView = (AMLiveMapProgramPanelTextView *) theObject;
                NSDictionary *theFontAttr = [curObject objectForKey:@"theFontAttr"];
                double theIndent = [[curObject objectForKey:@"indent"] doubleValue];
                
                [self updateTextView:theTextView withFontAttr:theFontAttr andIndent:theIndent];
            } else if ( [theObject isKindOfClass:[WebView class]] ) {
                
                WebView *curVideoStream = (WebView *) theObject;
                [self updateWebView:curVideoStream];
            }
            
        }
        
        [self resetDocumentSize:NSMakeSize(self.bounds.size.width, self.totalH)];
        
        
    }
}

- (void) updateWebView:(WebView *)theWebView {
    [theWebView setFrame:NSMakeRect(0, self.totalH, self.frame.size.width, ((3*self.frame.size.width)/4))];
    
    self.totalH = theWebView.frame.size.height + self.bottomMargin;
}

- (void) updateTextView:(AMLiveMapProgramPanelTextView *)theTextView withFontAttr:(NSDictionary *)theFontAttr andIndent:(double)theIndent {
    
    //Get the string from the textview
    NSString *curString = [[theTextView textStorage] string];
    
    NSAttributedString *theAttrString = [[NSAttributedString alloc] initWithString:curString attributes:theFontAttr];
    
    double newStringH = [theAttrString boundingRectWithSize:NSMakeSize(self.bounds.size.width, 0) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading].size.height;
    
    NSSize newTextViewSize = NSMakeSize(self.bounds.size.width, newStringH);
    NSPoint newTextViewOrigin = NSMakePoint(0 + theIndent, self.totalH);
    
    [theTextView setFrameSize:newTextViewSize];
    [theTextView setFrameOrigin:newTextViewOrigin];
    
    self.totalH += (newStringH + self.bottomMargin);
    
}

- (void)resetDocumentSize:(NSSize)theSize {
    [self setFrameSize:theSize];
    [self setBoundsSize:theSize];
    
    self.curSize = self.bounds;
}

- (BOOL)isFlipped{
    return YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowDidResizeNotification object:nil];
}

@end
