//
//  AMUserGroupServer.h
//  UserGroupModule
//
//  Created by 王 为 on 3/20/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMUserGroupServerDelegate.h"


@interface AMUserGroupServer : NSObject

@property int listenPort;
@property id<AMUserGroupServerDelegate> delegate;


-(BOOL)startServer;
-(void)stopServer;


@end
