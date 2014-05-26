//
//  AppDelegate.m
//  AMMesherTest
//
//  Created by Wei Wang on 5/25/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AppDelegate.h"
#import "AMUser.h"
#import "AMMesher.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    AMMesher* mesher = [AMMesher sharedAMMesher];
    
    [mesher startLoalMesher];
}

-(void)AMUsertest{
    AMUser* user = [[AMUser alloc] init];
    user.nickName = @"test";
    
    AMUserPortMap* pm1 = [[AMUserPortMap alloc] init];
    pm1.portName = @"test";
    pm1.internalPort = @"12345";
    pm1.natMapPort = @"45321";
    
    NSString* jsonStr1 = [pm1 jsonString];
    NSLog(jsonStr1);
    
    AMUserPortMap* pm2 = [[AMUserPortMap alloc] init];
    pm2.portName = @"test2";
    pm2.internalPort = @"12345";
    pm2.natMapPort = @"45321";
    
    NSString* jsonStr2 = [pm2 jsonString];
    NSLog(jsonStr2);
    
    [user.portMaps addObject:pm1];
    [user.portMaps addObject:pm2];
    
    NSString* jsonStr3 = [user jsonString];
    NSLog(jsonStr3);
    NSLog([user md5String]);
}

@end
