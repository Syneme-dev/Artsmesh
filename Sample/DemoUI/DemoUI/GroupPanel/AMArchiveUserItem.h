//
//  AMArchiveUserItem.h
//  DemoUI
//
//  Created by 王为 on 20/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMOutlineItem.h"
#import "AMCoreData/AMCoreData.h"

@interface AMArchiveUserItem : AMOutlineItem

+(AMArchiveUserItem *)itemFromArchiveUser:(AMStaticUser *)user;
@property AMStaticUser *userData;

@end
