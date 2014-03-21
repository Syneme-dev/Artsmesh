//
//  AMLocalMesherDelegate.m
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMLocalMesherDelegate.h"
#import "AMLocalMesherInterface.h"
#import "AMETCDManager.h"

@implementation AMLocalMesherDelegate

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection
{
    NSXPCInterface* interface = [NSXPCInterface interfaceWithProtocol:@protocol(AMLocalMesherInterface)];
    
    newConnection.exportedInterface = interface;
    newConnection.exportedObject = [[AMETCDManager alloc] init];
    
    [newConnection resume];
    
    return YES;
}

@end
