 //
//  AMLeaderElecter.m
//  AMMesher
//
//  Created by Wei Wang on 3/22/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMLeaderElecter.h"
#import "AMMesherStateMachine.h"
#import "AMAppObjects.h"
#import "AMSystemConfig.h"

#define MESHER_SERVICE_TYPE @"_ammesher._tcp."
#define MESHER_SERVICE_NAME @"am-mesher-service"

@implementation AMLeaderElecter
{
    NSNetServiceBrowser*  _mesherServiceBrowser;
    NSNetService* _myMesherService;
    NSMutableArray* _allMesherServices;
}

- (id)init
{
    if (self = [super init]) {
        AMMesherStateMachine* machine =[[AMAppObjects appObjects] objectForKey:AMMesherStateMachineKey];
        NSAssert(machine, @"mesher state machine can not be nil!");
        [machine addObserver:self forKeyPath:@"mesherState"
                     options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                     context:nil];
        
        _allMesherServices = [[NSMutableArray alloc] init];
    }
    
    return self;
}


-(void)kickoffElectProcess
{
    [self publishLocalMesher];
}


-(void)publishLocalMesher
{
    AMSystemConfig* config = [[AMAppObjects appObjects ] valueForKey:AMSystemConfigKey];
    NSAssert(config, @"system config should not be nil");
    
    int port = [config.myServerPort intValue];
 	_myMesherService = [[NSNetService alloc] initWithDomain:@"local."
                                                       type:MESHER_SERVICE_TYPE
                                                       name:MESHER_SERVICE_NAME
                                                       port:port];
    NSAssert(_myMesherService, @"alloc Mesher Failed!");
	[_myMesherService scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                forMode:NSRunLoopCommonModes];
	[_myMesherService setDelegate:self];
	[_myMesherService publish];
}


-(void)browseLocalMesher
{
    if (_mesherServiceBrowser == nil) {
         _mesherServiceBrowser = [[NSNetServiceBrowser alloc] init];
         _mesherServiceBrowser.delegate = self;
    }

    [_mesherServiceBrowser searchForServicesOfType:MESHER_SERVICE_TYPE inDomain:@"local."];
}


-(void)resolveLocalMesher{
    
    if ([_allMesherServices count] == 0){
        return;
    }
    
    NSNetService* service = [_allMesherServices objectAtIndex:0];
    if(service.hostName == nil){
        service.delegate  = self;
        [service resolveWithTimeout:5.0];
    }
}


-(void)stopElector
{
    [self stopBrowser];
    [self unpublishLocalMesher];
}


- (void) stopBrowser
{
    if (_mesherServiceBrowser == nil ){
        return;
    }
    
    [_mesherServiceBrowser stop];
    _mesherServiceBrowser = nil;
    
    [_allMesherServices removeAllObjects];
}


- (void) unpublishLocalMesher
{
    if (_myMesherService){
		[_myMesherService stop];
		[_myMesherService removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
		_myMesherService = nil;
	}
}


#pragma mark -
#pragma mark NSNetServiceBrowser Delegate Method Implementations

// New service was found
- (void) netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser
            didFindService:(NSNetService *)netService
                moreComing:(BOOL)moreServicesComing
{
    if ( ![_allMesherServices containsObject:netService] ){
        [_allMesherServices addObject:netService];
    }
    
    if ( moreServicesComing ){
        return;
    }
    
    [self resolveLocalMesher];
}


- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser
         didRemoveService:(NSNetService *)netService
               moreComing:(BOOL)moreServicesComing
{
    [_allMesherServices removeObject:netService];
    
    if ( moreServicesComing ){
        return;
    }
    
    [self publishLocalMesher];
}

// Called when net service has been successfully resolved
- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
    NSLog(@"service:%@ can be resloved, hostname:%@, port:%ld\n", sender.name, sender.hostName, (long)sender.port);
    
    
    NSString* hostName = sender.hostName;
    if ([hostName hasSuffix:@"."]) {
        hostName = [hostName substringToIndex:[hostName length] - 1];
        hostName = [hostName lowercaseString];
    }
    
    AMSystemConfig* config = [[AMAppObjects appObjects] objectForKey:AMSystemConfigKey  ];
    NSAssert(config, @"system config can not be nil");
    
    config.localServerAddr = hostName;
    config.localServertPort = [NSString stringWithFormat:@"%ld", sender.port];
    
    AMMesherStateMachine* machine = [[AMAppObjects appObjects] objectForKey:AMMesherStateMachineKey];
    NSAssert(machine, @"mesher state machine should not be nil");
    [machine setMesherState:kMesherLocalClientStarting];
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
    NSLog(@"service:%@ can not be resloved!\n", sender.name);
    [self publishLocalMesher];
}


#pragma mark -
#pragma mark NSNetService Delegate Method Implementations
- (void) netService:(NSNetService*)sender didNotPublish:(NSDictionary*)errorDict
{
    if ( sender != _myMesherService ){
        return;
    }

    [self browseLocalMesher];
}


- (void) netServiceDidPublish:(NSNetService *)sender
{
    NSLog(@" >> netServiceDidPublish: %@", [sender name]);
    
    NSString* hostName = [[NSHost currentHost] name];
    
    AMSystemConfig* config = [[AMAppObjects appObjects] objectForKey:AMSystemConfigKey  ];
    NSAssert(config, @"system config can not be nil");
    
    config.localServerAddr = hostName;
    config.localServertPort = [NSString stringWithFormat:@"%ld", sender.port];

    AMMesherStateMachine* machine = [[AMAppObjects appObjects] objectForKey:AMMesherStateMachineKey];
    NSAssert(machine, @"mesher state machine should not be nil");
    [machine setMesherState:kMesherLocalServerStarting];
}


- (void) netServiceDidStop:(NSNetService *)sender
{
    NSLog(@" >> netServiceDidStop: %@", [sender name]);
}


#pragma mark -
#pragma   mark KVO
- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context
{
    if ([object isKindOfClass:[AMMesherStateMachine class]]){
        
        if ([keyPath isEqualToString:@"mesherState"]){
            
            //AMMesherState oldState = [[change objectForKey:@"old"] intValue];
            AMMesherState newState = [[change objectForKey:@"new"] intValue];
            
            switch(newState){
                case kMesherStarting:
                    [self kickoffElectProcess];
                    break;
                    
                case kMesherStopping:
                    [self stopElector];
                    break;
            
                default:
                    break;
                    //[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
            }
        }
    }
}


@end
