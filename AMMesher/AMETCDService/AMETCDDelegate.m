//
//  AMListenerDelegate.m
//  AMMesher
//
//  Created by Wei Wang on 3/22/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDDelegate.h"
#import "AMETCDServiceInterface.h"
#import "AMETCDManager.h"

@implementation AMETCDDelegate

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection
{
    NSXPCInterface* interface = [NSXPCInterface interfaceWithProtocol:@protocol(AMETCDServiceInterface)];
    
    newConnection.exportedInterface = interface;
    newConnection.exportedObject = [[AMETCDManager alloc] init];
    
    [newConnection resume];
    
    return YES;
}

@end