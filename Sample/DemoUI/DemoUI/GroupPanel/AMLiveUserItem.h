//
//  AMLiveUserItem.h
//  DemoUI
//
//  Created by 王为 on 19/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMOutlineItem.h"
#import "AMCoreData/AMCoreData.h"
#import "AMUserCellContentView.h"

@interface AMLiveUserItem : AMOutlineItem<AMUserCellContentViewDataSource>

+(AMLiveUserItem *)itemFromLiveUser:(AMLiveUser *)user;
@property AMLiveUser *userData;

-(BOOL)isLeader;
-(BOOL)isRunningOSC;
-(BOOL)isIPV6;

@end
