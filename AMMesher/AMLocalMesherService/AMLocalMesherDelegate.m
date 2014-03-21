//
//  AMLocalMesherDelegate.m
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMLocalMesherDelegate.h"
#import "AMLocalMesherInterface.h"
#import "AMLocalMesherService.h"

@implementation AMLocalMesherDelegate
{
    AMLocalMesherService* _service;
}


- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection
{
    if (_service == nil)
    {
        _service = [[AMLocalMesherService alloc] init];
    }
    
    NSXPCInterface* interface = [NSXPCInterface interfaceWithProtocol:@protocol(AMLocalMesherInterface)];
    
    newConnection.exportedInterface = interface;
    newConnection.exportedObject = _service;
    
    [newConnection resume];
    
    return YES;
}

@end
