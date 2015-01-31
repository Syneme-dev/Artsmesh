//
//  AMLiveGroupItem.h
//  DemoUI
//
//  Created by 王为 on 19/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMOutlineItem.h"
#import "AMGroupCellContentView.h"
#import "AMCoreData/AMCoreData.h"

@interface AMGroupItem : AMOutlineItem<AMGroupCellContentViewDataSource>

@property (nonatomic) AMLiveGroup* groupData;

+(AMGroupItem *)itemFromLiveGroup:(AMLiveGroup *)group;

-(BOOL)isBroadcasting;
-(BOOL)canLeave;
-(BOOL)canMerge;

@end
