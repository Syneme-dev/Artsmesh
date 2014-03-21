//
//  AMMesher.m
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMMesher.h"
#import "AMETCDServiceInterface.h"
#import "AMMesherPreference.h"
#import "AMLeaderElecter.h"


@implementation AMMesher
{
    AMLeaderElecter* _elector;
    
    NSXPCInterface* _myLocalMesherInterface;
    NSXPCConnection* _myLocalMehserConnection;
}

-(id)init
{
    if (self = [super init])
    {
        _elector = [[AMLeaderElecter alloc] init];
        
        _myLocalMesherInterface= [NSXPCInterface interfaceWithProtocol:
                                  @protocol(AMETCDServiceInterface)];
        
        _myLocalMehserConnection =    [[NSXPCConnection alloc]
                                       initWithServiceName:@"AM.AMLocalMesherService"];
        
        _myLocalMehserConnection.interruptionHandler = ^{
            NSLog(@"XPC connection was interrupted.");
        };
        
        _myLocalMehserConnection.invalidationHandler = ^{
            NSLog(@"XPC connection was invalidated.");
        };
        
        _myLocalMehserConnection.remoteObjectInterface = _myLocalMesherInterface;
        [_myLocalMehserConnection resume];
    }
    
    return self;
}


-(void)startLoalMesher
{
    [self startETCD];
    [_elector kickoffElectProcess];
    
    [_elector addObserver:self forKeyPath:@"state"
                  options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                  context:CFBridgingRetain([_elector class])];
}

-(void)stopLocalMesher
{
    [self stopETCD];
    [_elector stopElect];
    
    [_elector removeObserver:self forKeyPath:@"state"];
}


-(void)startETCD
{
    [_myLocalMehserConnection.remoteObjectProxy startService:nil reply:^(NSString *string) {
        NSLog(@"Did receive from XPC Service: %@", string);
    }];
}

-(void)stopETCD
{
    if(_myLocalMehserConnection)
    {
        [_myLocalMehserConnection.remoteObjectProxy stopService];
    }
}


#pragma mark -
#pragma mark KVO
- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context
{
    if ([keyPath isEqualToString:@"state"])
    {
//        Class classInfo = (Class)CFBridgingRelease(context);
//        NSString * className = [NSString stringWithCString:object_getClassName(classInfo)
//                                                  encoding:NSUTF8StringEncoding];
//        NSLog(@" >> class: %@, Age changed", className);
        
        NSLog(@" old state is %@", [change objectForKey:@"old"]);
        NSLog(@" new state is %@", [change objectForKey:@"new"]);
    }
    else
    {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}




@end
