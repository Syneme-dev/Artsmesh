//
//  AMOSCClient.h
//  AMOSCGroups
//
//  Created by 王为 on 13/11/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMOSCClient : NSObject

@property NSString* serverAddr;
@property NSString* serverPort;
@property NSString* remotePort;
@property NSString* rxPort;
@property NSString* txPort;
@property NSString* userName;
@property NSString* userPwd;
@property NSString* groupName;
@property NSString* groupPwd;
@property NSString* monitorAddr;
@property NSString* monitorPort;

-(BOOL)startOscClient;
-(void)stopOscClient;

@end
