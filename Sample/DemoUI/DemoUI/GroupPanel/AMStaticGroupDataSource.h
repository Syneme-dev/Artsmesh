//
//  AMStaticGroupDataSource.h
//  DemoUI
//
//  Created by 王 为 on 7/10/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMStaticGroupDataSource : NSObject<NSOutlineViewDelegate, NSOutlineViewDataSource>

@property NSArray* staticGroups;

-(void)reloadGroups;
-(void)doubleClickOutlineView:(id)sender;

@end
