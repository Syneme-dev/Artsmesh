//
//  AMPopupMenuItem.m
//  DemoUI
//
//  Created by Wei Wang on 5/7/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMPopupMenuItem.h"
#import <UIFramework/AMUIConst.h>
#import "AMAppDelegate.h"
#import "AMMouseOverButtonView.h"

@implementation AMPopupMenuItem

-(id)initWithTitle:(NSString *)aString action:(SEL)aSelector keyEquivalent:(NSString *)charCode
             width:(CGFloat)width
{
//    NSDictionary *attributes = [NSDictionary
//                                dictionaryWithObjectsAndKeys:
//                                [NSColor whiteColor], NSForegroundColorAttributeName,
//                                [NSFont systemFontOfSize: [NSFont systemFontSize]],
//                                NSFontAttributeName,
//                                nil];
//    NSAttributedString *attrTitle = [[NSAttributedString alloc]
//                                     initWithString:aString                                     attributes:attributes];
//
//    [self setAttributedTitle:attrTitle];
    [self setTitle:aString];
//    self =[ super initWithTitle:aString action:aSelector keyEquivalent:charCode];
    if (self){
        self.theLabel = [[AMMouseOverButtonView alloc] initWithFrame:NSMakeRect(10, 8, width, 20)];
        [self.theLabel setBordered:NO];
        [[self.theLabel cell] setBackgroundColor:UI_Color_b7b7b7];
        [self.theLabel setAction:@selector(menuItem1Action:)];
        [self.theLabel setTarget:self];
        [self.theLabel setEnabled:YES];
        [self.theLabel setFocusRingType:NSFocusRingTypeNone];
        [self setView:self.theLabel];
        [self.theLabel setTitle:aString];
    }
    return self;
}



- (IBAction)menuItem1Action:(id)sender
{
    AMPopupMenuItem *popItem=(AMPopupMenuItem*)[sender enclosingMenuItem];
    [self.popupButton setTitle:popItem.theLabel.title];
//    [self.popupButton setAttributedTitle:nil];
//    [self.popupButton setAttributedTitle:attrTitle];
//    [self.popupButton selectItemAtIndex:1];
    [self.popupButton setNeedsDisplay:YES];
    [self.popupButton synchronizeTitleAndSelectedItem];
    [self.popupButton updateCell:self.popupButton.cell];
    
    // dismiss the menu
    	NSMenu *menu = [[sender enclosingMenuItem] menu];
    	[menu cancelTracking];
}




@end
