//
//  AMLiveGroupItem.h
//  DemoUI
//
//  Created by 王为 on 19/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMOutlineItem.h"
#import "AMLocalGroupCellContentView.h"
#import "AMCoreData/AMCoreData.h"

@interface AMLiveGroupItem : AMOutlineItem<AMLocalGroupCellContentViewDataSource>

@property (nonatomic) AMLiveGroup* groupData;

+(AMLiveGroupItem *)itemFromLiveGroup:(AMLiveGroup *)group;

-(BOOL)isBroadcasting;

@end
