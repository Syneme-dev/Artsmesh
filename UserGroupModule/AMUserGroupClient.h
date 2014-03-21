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

-(id)initWithDataModel:(AMUserGroupModel*)model;

-(void)getGroups:(NSData*)serverAddr;

-(void)getUsers:(NSData*)serverAddr;

-(void)sendMyInfo;

-(void)sendRequest:(NSData*)data
            toAddr:(NSData*)addr;

@end
