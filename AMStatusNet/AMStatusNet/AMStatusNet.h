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

-(BOOL)quickRegisterAccount:(NSString*)account password:(NSString*)password;
-(BOOL)registerAccount:(AMStaticUser*)user password:(NSString*)password;
-(BOOL)loginAccount:(NSString*)account password:(NSString*)password;
-(BOOL)followGroup:(NSString*)groupName;
-(BOOL)createGroup:(NSString*)groupName;
-(BOOL)postMessageToStatusNet:(NSString*)status;

-(void)loadGroups;

+(AMStatusNet*)shareInstance;

@end
