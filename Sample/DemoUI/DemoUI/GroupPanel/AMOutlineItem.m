//
//  AMOutlineItem.m
//  DemoUI
//
//  Created by 王为 on 19/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMOutlineItem.h"


@implementation AMOutlineItem

-(BOOL)hideBar
{
    return YES;
}


-(NSColor *)barColor
{
    return [NSColor grayColor];
}


+(AMOutlineItem *)itemFromLabel:(NSString *)title
{
    AMOutlineItem *item = [[AMOutlineItem alloc] init];
    item.title = title;
    
    return item;
}


@end
