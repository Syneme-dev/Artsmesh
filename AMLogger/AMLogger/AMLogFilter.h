//
//  AMLogFilter.h
//  AMLogger
//
//  Created by 王为 on 23/10/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMLogger.h"

@interface AMLogFilter : NSObject

-(AMLogCategory)logItemCategory:(NSString*)logItem;


@end
