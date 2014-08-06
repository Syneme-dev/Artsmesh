//
//  AMStatusNet.h
//  AMStatusNet
//
//  Created by Wei Wang on 7/21/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMCoreData/AMCoreData.h"

@interface AMStatusNet : NSObject

@property NSString* homePage;

-(BOOL)registerAccount:(NSString*)account password:(NSString*)password;
-(BOOL)loginAccount:(NSString*)account password:(NSString*)password;
-(BOOL)followGroup:(NSString*)groupName;
-(BOOL)createGroup:(NSString*)groupName;
-(BOOL)postMessageToStatusNet:(NSString*)status;

-(void)loadUserAvatar:(NSString*)userName
      requestCallback:(void (^)(NSImage* image, NSError* error))requestCallback;

-(void)loadGroupAvatar:(NSString*)groupName
       requestCallback:(void (^)(NSImage* image, NSError* error))requestCallback;

-(void)loadGroups;

+(AMStatusNet*)shareInstance;

@end
