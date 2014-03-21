//
//  AMUeserGroupModel.h
//  UserGroupModule
//
//  Created by Wei Wang on 3/21/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMUserGroupModel : NSObject

@property NSMutableDictionary* groups;
@property NSMutableDictionary* users;
@property NSMutableDictionary* myself;

@property NSData* serverAddr;
@end
