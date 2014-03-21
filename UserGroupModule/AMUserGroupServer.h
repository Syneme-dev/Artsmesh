//
//  AMUserGroupServer.h
//  UserGroupModule
//
//  Created by 王 为 on 3/20/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AMUserGroupCtrlSrvDelegate;
@class AMUserGroupDataDeletage;

@interface AMUserGroupServer : NSObject

@property int listenPort;

-(BOOL)startServer;
-(void)stopServer;


@end
