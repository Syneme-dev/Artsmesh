//
//  AMFoundryFontView.m
//  UIFramewrok
//
//  Created by xujian on 4/27/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMFoundryFontView.h"

@implementation AMFoundryFontView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
               // Initialization code here.
    }
    return self;
}


- (void)textDidBeginEditing:(NSNotification *)notification{
}
- (void)mouseMoved:(NSEvent *)theEvent {
    
    NSTextView *responder=(NSTextView*)[self.window firstResponder];
//    NSString *aabss=[aa string ];
    if((NSTextField*)[responder delegate] ==self){
        NSTextView *editor= (NSTextView*)[self currentEditor];
        if ([editor shouldDrawInsertionPoint]){
//             [editor setInsertionPointColor:[NSColor blueColor] ];
//            [editor lockFocus];
//            [editor drawInsertionPointInRect:NSMakeRect(0,0,4,20) color:[NSColor redColor] turnedOn:YES];
//            [editor unlockFocus];
        }

    }

    [super mouseMoved:theEvent];
}
- (void)drawRect:(NSRect)dirtyRect
{
    [self setFont: [NSFont fontWithName: @"FoundryMonoline-Bold" size: self.font.pointSize]];
    [super drawRect:dirtyRect];
    


    
    // Drawing code here.
}
- (void)viewWillDraw {

    NSTextView *editor= (NSTextView*)[self currentEditor];
    //496585
    NSColor *color= [NSColor colorWithCalibratedRed:(56)/255.0f green:(81)/255.0f blue:(115)/255.0f alpha:1.0f] ;

    [editor setInsertionPointColor:color ];
    

}

- (NSCursor *)creationCursor {
    
    // By default we use the crosshairs cursor.
    static NSCursor *crosshairsCursor = nil;
    if (!crosshairsCursor) {
        NSImage *crosshairsImage = [NSImage imageNamed:@"cursor"];
        NSSize crosshairsImageSize = [crosshairsImage size];
        crosshairsCursor = [[NSCursor alloc] initWithImage:crosshairsImage hotSpot:NSMakePoint((crosshairsImageSize.width / 2.0), (crosshairsImageSize.height / 2.0))];
    }
    return crosshairsCursor;
    
}

//Note:uncommend this method to change cusror.
//- (void)resetCursorRects{
//    [self discardCursorRects];
//    NSImage *image= [NSImage imageNamed:@"cursor"];
//    [image setSize:NSMakeSize(4,20)];
//    NSCursor *cursor=[[NSCursor alloc] initWithImage:image hotSpot:NSMakePoint(0, 0)];
//    [self addCursorRect:self.bounds cursor:cursor];
//    if([self.window firstResponder] ==self)
//    {
//         [cursor setOnMouseExited:YES];
//    }
//}

@end
