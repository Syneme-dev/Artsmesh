//
//  NSButton+BlueColor.m
//  UIFramework
//
//  Created by xujian on 7/31/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMBlueButton.h"
#import "AMButtonHandler.h"
@implementation AMBlueButton
//-(void)
//-(void)awakeFromNib{
//     [AMButtonHandler changeTabTextColor:self toColor:UI_Color_blue];
//    [self setNeedsDisplay:YES];
//     }
-(void)viewWillDraw
{
    [AMButtonHandler changeTabTextColor:self toColor:UI_Color_blue];

}


@end
