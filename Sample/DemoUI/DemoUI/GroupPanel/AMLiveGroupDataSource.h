//
//  AMLiveGroupDataSource.h
//  DemoUI
//
//  Created by Wei Wang on 7/10/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMLiveGroupDataSource : NSObject <NSOutlineViewDelegate, NSOutlineViewDataSource>

@property NSArray* liveGroups;

-(void)reloadGroups;
-(void)doubleClickOutlineView:(id)sender;

@end
