//
//  AMUserGroupServer.h
//  UserGroupModule
//
//  Created by 王 为 on 3/20/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>


@class AMUser;
@interface AMUserGroupServer : NSObject

@property int ctrlPort;
@property int dataPort;

@property NSMutableDictionary* groups;
@property NSMutableDictionary* users;
@property NSMutableDictionary* myself;

-(void)sendCtrlData:(NSData*)data toAddress:address;
-(BOOL)startServer;
-(void)stopServer;


@end
