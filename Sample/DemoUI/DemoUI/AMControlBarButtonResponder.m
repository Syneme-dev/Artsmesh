//
//  AMControlBarButtonResponder.m
//  Artsmesh
//
//  Created by KeysXu on 6/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMControlBarButtonResponder.h"
#import "AMAppDelegate.h"

@implementation AMControlBarButtonResponder

//
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
//        [self setButtonType:NSToggleButton];
//
//        [self setAcceptsTouchEvents:YES];
//        [[self window] makeFirstResponder:self];
//        [[self window] setAcceptsMouseMovedEvents:YES];
//       
//        [self.cell setDoubleAction:@selector(scrollToPanel:)];
//         [self.cell setTarget:self];
//        [self addCursorRect:self.frame cursor:[NSCursor openHandCursor]];
    }
    return self;
}
//
//
//-(BOOL)becomeFirstResponder{
//    return YES;}
//-(BOOL)acceptsFirstResponder{
//    return YES;
//}

//-(void)viewWillDraw{
//
//
////    [self setTarget:self];
//    
////    [self.cell setDoubleAction:@selector(onSidebarDouble1Click:)];
//
//}



-(void)mouseDown:(NSEvent *)theEvent{
    //Note:worked for double click ,but will cause delay.
//    if(theEvent.clickCount>1 ){
//        [self scrollToPanel];
//        [self setNextResponder:nil];
//        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showHidePanel) object:nil];
//    }
//    else {
//        [self performSelector:@selector(showHidePanel) withObject:nil afterDelay:0.5];
//    }
    if(theEvent.modifierFlags&NSCommandKeyMask){
        [self scrollToPanel];
    }
    else{
    [self showHidePanel];
    }
}


- (void)showHidePanel {
    
    AMAppDelegate *appDelegate=AM_APPDELEGATE;
    NSString *panelId=
    [[NSString stringWithFormat:@"%@_PANEL",self.identifier ] uppercaseString];
    if(self.state==NSOffState)
    {
        [appDelegate.mainWindowController createPanelWithType:panelId withId:panelId];
        
        [self setState:NSOnState];
    }
    else
    {
        [appDelegate.mainWindowController  removePanel:panelId];
        
        [self setState:NSOffState];

    }
}
-(void)superShowHidePanel:(NSEvent *)theEvent{
    [super mouseDown:theEvent];

}

-(void)rightMouseDown:(NSEvent *)theEvent{
    [self scrollToPanel];

}

- (void)scrollToPanel {
    AMAppDelegate *appDelegate=AM_APPDELEGATE;
    NSString *panelId=
    [[NSString stringWithFormat:@"%@_PANEL",self.identifier ] uppercaseString];
    AMPanelViewController *panelViewController = appDelegate.mainWindowController.panelControllers [panelId];
    if(panelViewController!=nil){
        [appDelegate.mainWindowController.mainScrollView.animator.contentView scrollToPoint:panelViewController.view.superview.frame.origin];
    }
}

-(void)resetCursorRects{
          NSTrackingArea* trackArea = [[NSTrackingArea alloc]
                                initWithRect:self.frame
                                         options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveInKeyWindow )
                                         owner:self
                                         userInfo:nil];
            [self addTrackingArea:trackArea];
//    [self addCursorRect:self.frame cursor:[NSCursor openHandCursor]];

}


- (void)mouseEntered:(NSEvent *)theEvent{
    return;
    AMAppDelegate *appDelegate=AM_APPDELEGATE;
    NSString *panelId=
    [[NSString stringWithFormat:@"%@_PANEL",self.identifier ] uppercaseString];
    AMPanelViewController *panelViewController = appDelegate.mainWindowController.panelControllers [panelId];
    if(panelViewController!=nil){
        [appDelegate.mainWindowController.mainScrollView.contentView scrollToPoint:panelViewController.view.superview.frame.origin];
    }

}

@end
