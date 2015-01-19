//
//  AMOutlineItem.h
//  DemoUI
//
//  Created by 王为 on 19/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMOutlineCellContentView.h"


@interface AMOutlineItem : NSObject <AMOutlineCellContentViewDataSource>

@property (nonatomic, copy) NSString *title;
@property (nonatomic) NSArray *subItems;

-(BOOL)hideBar;
-(NSColor *)barColor;

+(AMOutlineItem *)itemFromLabel:(NSString *)title;

@end
