//
//  AMFoundryFontFieldTextView.m
//  UIFramework
//
//  Created by Brad Phillips on 12/4/16.
//  Copyright © 2016 Artsmesh. All rights reserved.
//

#import "AMFoundryFontFieldTextView.h"

@implementation AMFoundryFontFieldTextView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.curTextColor = [AMTheme sharedInstance].colorTextField;
    [self setTextColor:self.curTextColor];
    
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void) changeTheme:(NSNotification *) notification {
    //Update text properties
    [super changeTheme:notification];
    
    self.curTextColor = self.curTheme.colorTextField;
    [self setTextColor:self.curTextColor];
    [self setNeedsDisplay:YES];
}

@end
