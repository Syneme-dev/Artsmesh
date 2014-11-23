//
//  AMOSCGroupClientViewController.h
//  AMOSCGroups
//
//  Created by wangwei on 13/11/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AMOSCGroupClientViewController : NSViewController

@property NSString* serverAddr;
@property NSString* serverPort;
@property NSString* remotePort;
@property NSString* txPort;
@property NSString* rxPort;
@property NSString* userName;
@property NSString* userPwd;
@property NSString* groupName;
@property NSString* groupPwd;
@property NSString* monitorAddr;
@property NSString* monitorPort;

@end
