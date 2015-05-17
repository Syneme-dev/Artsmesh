//
//  AMBlueBorderButton.m
//  UIFramework
//
//  Created by KeysXu on 5/17/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMBlueBorderButton.h"

#import "AMButtonHandler.h"

@implementation AMBlueBorderButton
-(void)viewWillDraw
{
    [AMButtonHandler changeTabTextColor:self toColor:UI_Color_blue];
    [self.layer setBorderWidth:1.0];
    [self.layer setBorderColor: UI_Color_blue.CGColor];
    
}


@end
