//
//  AMArchiveGroupItem.h
//  DemoUI
//
//  Created by 王为 on 20/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMOutlineItem.h"
#import "AMCoreData/AMCoreData.h"

@interface AMArchiveGroupItem : AMOutlineItem

@property AMStaticGroup *archiveGroupData;

+(AMArchiveGroupItem *)itemFromArchiveGroup:(AMStaticGroup *)archiveGroup;

@end
