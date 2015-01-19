//
//  AMLiveUserItem.h
//  DemoUI
//
//  Created by 王为 on 19/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMOutlineItem.h"
#import "AMCoreData/AMCoreData.h"

@interface AMLiveUserItem : AMOutlineItem

+(AMLiveUserItem *)itemFromLiveUser:(AMLiveUser *)user;

@property AMLiveUser *userData;

@end
