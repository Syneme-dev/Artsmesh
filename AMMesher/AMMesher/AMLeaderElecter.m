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
#import "AMPreferenceManager/AMPreferenceManager.h"

#define MESHER_SERVICE_TYPE @"_http._tcp."
#define MESHER_SERVICE_NAME @"am-mesher-service"

@implementation AMLeaderElecter
{
    NSNetServiceBrowser*  _mesherServiceBrowser;
    NSNetService* _myMesherService;
    NSMutableArray* _allMesherServices;
    
    NSTimer *browseTimer;
    BOOL locallyMeshed;
    
    int mesherServiceCount;
}

- (id)init
{
    if (self = [super init]) {
        mesherServiceCount = 1;
        
        [[AMMesher sharedAMMesher] addObserver:self forKeyPath:@"clusterState"
                     options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                     context:nil];
        
        _allMesherServices = [[NSMutableArray alloc] init];
    }
    
    return self;
}


-(void)kickoffElectProcess
{
    NSString *LSConfig = [[NSUserDefaults standardUserDefaults] stringForKey:Preference_Key_Cluster_LSConfig];
    
    NSNotification* notification = [[NSNotification alloc]
                                    initWithName: AM_LOCAL_MESHER_MESHING_NOTIFICATION
                                    object:nil
                                    userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
    AMLog(kAMInfoLog, @"AMMesher", @"kickoff local server elector process!");
    
    browseTimer = nil;
    locallyMeshed = NO;
    
    if ([LSConfig isEqualToString:@"DISCOVER"]) {
        [self browseLocalMesher];
    } else if ([LSConfig isEqualToString:@"SELF"]) {
        [self publishLocalMesher];
    } else {
        //Manual IP is selected, carry on with client registration and skip Bonjour
        [[AMMesher sharedAMMesher] setClusterState:kClusterClientRegistering];
    }
}


-(void)publishLocalMesher
{
    NSString *serviceName = MESHER_SERVICE_NAME;
    if (mesherServiceCount > 1) {
        serviceName = [NSString stringWithFormat:@"%@-%i", MESHER_SERVICE_NAME, mesherServiceCount];
    }
    
    int port = [[[NSUserDefaults standardUserDefaults]
                stringForKey:Preference_Key_General_LocalServerPort] intValue];
    
 	_myMesherService = [[NSNetService alloc] initWithDomain:@"local."
                                                       type:MESHER_SERVICE_TYPE
                                                       name:serviceName
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

-(void)onSearchTimeout:(NSTimer *)theTimer {
    if (!locallyMeshed) {
        AMLog(kAMInfoLog, @"AMMesher", @"Done searching for Bonjour Services.");
    
        if ([_allMesherServices count] == 0){
            AMLog(kAMInfoLog, @"AMMesher", @"AM Mesher Service, not found. Let's publish one.");
        
            [self stopBrowser];
            [self publishLocalMesher];
        
            return;
        } else {
            return;
        }
        } else {
            return;
    }
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


// Search for Bonjour Services is starting..
- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser {
    browseTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(onSearchTimeout:) userInfo:nil repeats:YES];
    
    AMLog(kAMErrorLog, @"AMMesher", @"Searching for existing Bonjour services..");
    return;
}

#pragma mark -
#pragma mark NSNetServiceBrowser Delegate Method Implementations

// New service was found
- (void) netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser
            didFindService:(NSNetService *)netService
                moreComing:(BOOL)moreServicesComing
{
    
    if ([[netService name] hasPrefix:MESHER_SERVICE_NAME] && [netService.domain isEqualToString:@"local."]) {
        AMLog(kAMInfoLog, @"AMMesher", @"found a local mesher service, will resolve it.");
        if ( ![_allMesherServices containsObject:netService]){
            [_allMesherServices addObject:netService];
        }
        
        [self resolveLocalMesher];
        
    } else if ( moreServicesComing ){
        return;
    }

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
    locallyMeshed = YES;
    
    AMSystemConfig* config = [AMCoreData shareInstance].systemConfig;
    
    NSHost *host = [NSHost hostWithName:sender.hostName];
    if (config.localServerIps == nil) {
        config.localServerIps = config.localServerHost.addresses;
    }
    config.localServerHost = host;
    config.localServerPort = [NSString stringWithFormat:@"%ld", (long)sender.port];
    
    AMLog(kAMInfoLog, @"AMMesher", @"local service resolved, hostname:%@, port:%d",
          sender.hostName, sender.port);
    
    [self stopBrowser];
    
    [[AMMesher sharedAMMesher] setClusterState:kClusterClientRegistering];
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
    NSString *errorCode = [NSString stringWithFormat:@"Bonjour service resolve error code: %@", [errorDict objectForKey:@"NSNetServicesErrorCode"]];
    AMLog(kAMWarningLog, @"AMMesher", @"local service didn't be resolved, try to publish one");
    AMLog(kAMWarningLog, @"AMMesher", errorCode);
    [self publishLocalMesher];
}


#pragma mark -
#pragma mark NSNetService Delegate Method Implementations
- (void) netService:(NSNetService*)sender didNotPublish:(NSDictionary*)errorDict
{
    if ( sender != _myMesherService ){
        return;
    }
    
    NSString *LSConfig = [[NSUserDefaults standardUserDefaults] stringForKey:Preference_Key_Cluster_LSConfig];
    
    if ([LSConfig isEqualToString: @"DISCOVER"]) {
        AMLog(kAMWarningLog, @"AMMesher", @"local server publish failed, maybe already exist, will try to find one");
        browseTimer = nil;
        [self browseLocalMesher];
    } else if ([LSConfig isEqualToString:@"SELF"]) {
        AMLog(kAMWarningLog, @"AMMesher", @"local server publish failed, service with same name already exists, will try publishing under a modified name.");
        mesherServiceCount++;
        [self publishLocalMesher];
    }
    
}


- (void) netServiceDidPublish:(NSNetService *)sender
{
    locallyMeshed = YES;
    
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
