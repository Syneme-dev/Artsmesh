//
//  AMETCDSyncDelegate.m
//  AMMesher
//
//  Created by Wei Wang on 3/22/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDSyncDelegate.h"
#import "AMETCDSyncInterface.h"
#import "AMETCDSyncService.h"

@implementation AMETCDSyncDelegate

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection
{
    NSXPCInterface* interface = [NSXPCInterface interfaceWithProtocol:@protocol(AMETCDSyncInterface)];
    
    newConnection.exportedInterface = interface;
    newConnection.exportedObject = [[AMETCDSyncService alloc] init];
    
    [newConnection resume];
    
    return YES;
}

@end
