 //
//  AMLeaderElecter.m
//  AMMesher
//
//  Created by Wei Wang on 3/22/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMLeaderElecter.h"
#import "AMMesher.h"
#import "AMCoreData/AMCoreData.h"
#import "AMLogger/AMLogger.h"
#import "AMCommonTools/AMCommonTools.h"

#define MESHER_SERVICE_TYPE @"_http._tcp."
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
        [[AMMesher sharedAMMesher] addObserver:self forKeyPath:@"clusterState"
                     options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                     context:nil];
        
        _allMesherServices = [[NSMutableArray alloc] init];
    }
    
    return self;
}


-(void)kickoffElectProcess
{
    AMLog(kAMInfoLog, @"AMMesher", @"kickoff local server elector process!");
    [self publishLocalMesher];
}


-(void)publishLocalMesher
{
    AMSystemConfig* config = [AMCoreData shareInstance].systemConfig;
    
    int port = [config.localServerPort intValue];
 	_myMesherService = [[NSNetService alloc] initWithDomain:@""
                                                       type:MESHER_SERVICE_TYPE
                                                       name:MESHER_SERVICE_NAME
                                                       port:port];
    if (_myMesherService == nil) {
        AMLog(kAMErrorLog, @"AMMesher", @"create bonjour service failed");
        return;
    }
    
    
	[_myMesherService scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                forMode:NSRunLoopCommonModes];
	[_myMesherService setDelegate:self];
	[_myMesherService publish];
}


-(void)browseLocalMesher
{
    _mesherServiceBrowser = [[NSNetServiceBrowser alloc] init];
    _mesherServiceBrowser.delegate = self;
   
    [_mesherServiceBrowser searchForServicesOfType:MESHER_SERVICE_TYPE inDomain:@""];
}


-(void)resolveLocalMesher{
    
    if ([_allMesherServices count] == 0){
        return;
    }
    
    NSNetService* service = [_allMesherServices objectAtIndex:0];
    service.delegate  = self;
    [service resolveWithTimeout:5.0];
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
    
    AMLog(kAMInfoLog, @"AMMesher", @"found a local mesher service, will resolve it.");
    
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
    AMSystemConfig* config = [AMCoreData shareInstance].systemConfig;
    
    NSHost *host = [NSHost hostWithName:sender.hostName];
    if (config.localServerIps == nil) {
        config.localServerIps = config.localServerHost.addresses;
    }
    config.localServerHost = host;
    config.localServerPort = [NSString stringWithFormat:@"%ld", (long)sender.port];
    
    AMLog(kAMInfoLog, @"AMMesher", @"local service resolved, hostname:%@, port:%d",
          sender.hostName, sender.port);
    
    [[AMMesher sharedAMMesher] setClusterState:kClusterClientRegisting];
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
    AMLog(kAMWarningLog, @"AMMesher", @"local service didn't be resolved, try to publish one");
    [self publishLocalMesher];
}


#pragma mark -
#pragma mark NSNetService Delegate Method Implementations
- (void) netService:(NSNetService*)sender didNotPublish:(NSDictionary*)errorDict
{
    if ( sender != _myMesherService ){
        return;
    }
    
    AMLog(kAMWarningLog, @"AMMesher", @"local server publish failed, maybe already exist, will try to find one");
    [self browseLocalMesher];
}


- (void) netServiceDidPublish:(NSNetService *)sender
{
    AMSystemConfig* config = [AMCoreData shareInstance].systemConfig;
    config.localServerHost = [NSHost currentHost];
    
    if (config.localServerIps == nil) {
        config.localServerIps = config.localServerHost.addresses;
    }
    
    config.localServerPort = [NSString stringWithFormat:@"%ld", sender.port];
    
    AMLog(kAMInfoLog, @"AMMesher", @"local server published, service name: %@, host name:%@, port:%@",
          [sender name],
          config.localServerHost.name,
          config.localServerPort);
    
    [[AMMesher sharedAMMesher] setClusterState:kClusterServerStarting];
}


- (void) netServiceDidStop:(NSNetService *)sender
{
    AMLog(kAMInfoLog, @"AMMesher", @"local server service stop publishing.");

}


#pragma mark -
#pragma   mark KVO
- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context
{
    if ([object isKindOfClass:[AMMesher class]]){
        
        if ([keyPath isEqualToString:@"clusterState"]){
            
            AMClusterState newState = [[change objectForKey:@"new"] intValue];
            
            switch(newState){
                case kClusterAutoDiscovering:
                    [self kickoffElectProcess];
                    break;
                    
                case kClusterStopping:
                    [self stopElector];
                    break;
            
                default:
                    break;
            }
        }
    }
}


@end
