//
//  AMUserGroupClient.h
//  UserGroupModule
//
//  Created by Wei Wang on 3/21/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMUserGroupClientDelegate.h"

@class AMUserGroupModel;
@interface AMUserGroupClient : NSObject

@property id<AMUserGroupClientDelegate> delegate;

-(void)getGroups:(NSData*)serverAddr;

-(void)getUsers:(NSData*)serverAddr;

-(void)RegsterUser:(NSData*)serverAddr name:(NSString*)userName withPort:(int)port;

-(void)UnregisterUser:(NSData*)serverAddr name:(NSString*)userName;

-(void)sendUserInfo:(NSData*)serverAddr userInfo:(NSString*)userInfo;


@end
