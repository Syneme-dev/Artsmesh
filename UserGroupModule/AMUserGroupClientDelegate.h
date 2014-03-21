//
//  AMUserGroupClientDelegate.h
//  UserGroupModule
//
//  Created by Wei Wang on 3/21/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AMUserGroupClientDelegate <NSObject>

-(void)didGetGroups:(id)res;

-(void)didGetUsers:(id)res;

-(void)didRegsterUser:(id)res;

@end
