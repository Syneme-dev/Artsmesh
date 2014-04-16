//
//  AMCommunicator.h
//  AMMesher
//
//  Created by Wei Wang on 4/16/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMCommunicator : NSObject

-(void)goOnlineCommand:(NSString*)ip port:(NSString*)port;
-(void)joinGroupCommand:(NSString*)groupName ip:(NSString*)ip port:(NSString*)port;

@end
