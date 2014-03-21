//
//  AMUserGroupCtrlSrvDelegate.h
//  UserGroupModule
//
//  Created by Wei Wang on 3/21/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMUserGroupModel.h"
#import "AMUserGroupServer.h"

@interface AMUserGroupCtrlSrvDelegate : NSObject

@property AMUserGroupModel* model;
@property AMUserGroupServer* server;

-(id)initWithDataModel:(AMUserGroupModel*) m
            withServer:(AMUserGroupServer*) s;


@end
