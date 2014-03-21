//
//  AMUserGroupCtrlSrvDelegate.h
//  UserGroupModule
//
//  Created by Wei Wang on 3/21/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>


@class AMUserGroupServer;
@interface AMUserGroupCtrlSrvDelegate : NSObject

-(id)initWithDataSource:(AMUserGroupServer*)server;

@end
