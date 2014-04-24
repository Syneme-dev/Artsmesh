//
//  AMButtonHandler.m
//  UIFramewrok
//
//  Created by xujian on 4/22/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMButtonHandler.h"

@implementation AMButtonHandler


+(void)changeTabTextColor:(NSButton*) button toColor:(NSColor*)color{
    NSMutableAttributedString *colorTitle =
    [[NSMutableAttributedString alloc] initWithAttributedString:[button attributedTitle]];
    NSRange titleRange = NSMakeRange(0, [colorTitle length]);
    
    [colorTitle addAttribute:NSForegroundColorAttributeName
                       value:color
                       range:titleRange];
    
    [button setAttributedTitle:colorTitle];
}

@end
