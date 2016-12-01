//
//  AMFoundryFontFieldLabelView.m
//  UIFramework
//
//  Created by Brad Phillips on 11/30/16.
//  Copyright © 2016 Artsmesh. All rights reserved.
//

#import "AMFoundryFontFieldLabelView.h"

@implementation AMFoundryFontFieldLabelView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    //_curTheme = [AMTheme sharedInstance];
    //_curFontTextColor = _curTheme.colorTextFieldLabel;
    
    //[self setTextColor:_curFontTextColor];
    self.curTextColor = [AMTheme sharedInstance].colorTextFieldLabel;
    [self setTextColor:self.curTextColor];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}



- (void) changeTheme:(NSNotification *) notification {
    //Update text properties
    [super changeTheme:notification];
    
    self.curTextColor = self.curTheme.colorTextFieldLabel;
    [self setTextColor:self.curTextColor];
    [self setNeedsDisplay:YES];
}

@end
