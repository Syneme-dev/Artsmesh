//
//  AMLocalMesherService.m
//  AMMesher
//
//  Created by Wei Wang on 3/21/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMLocalMesherService.h"
#import "AMETCDManager.h"

#define MESHER_SERVICE_TYPE @"_ammesher._tcp."
#define MESHER_SERVICE_NAME @"am-mesher-service"

@implementation AMLocalMesherService
{
    NSNetServiceBrowser*  _mesherServiceBrowser;
    NSNetService* _myMesherService;
    NSMutableArray* _allMesherServices;
    
    AMETCDManager* _etcdManager;
    NSDictionary* _param;
}

-(id)init
{
    if(self = [super init])
    {
        _allMesherServices = [[NSMutableArray alloc]init];
        self.state = MESHER_STATE_STOP;
        self.servicePort = 0;
        _etcdManager = [[AMETCDManager alloc] init];
        
        [self browseLocalMesher];
    }
    
    return self;
}

-(BOOL)browseLocalMesher
{
    if(_mesherServiceBrowser != nil)
    {
        [self stopBrowser];
    }
    
    _mesherServiceBrowser = [[NSNetServiceBrowser alloc] init];
    _mesherServiceBrowser.delegate = self;
    [_mesherServiceBrowser searchForServicesOfType:MESHER_SERVICE_TYPE inDomain:@""];
    
    return YES;
}

- (void) stopBrowser
{
    if (_mesherServiceBrowser == nil )
    {
        return;
    }
    
    [_mesherServiceBrowser stop];
    _mesherServiceBrowser = nil;
    
    [_allMesherServices removeAllObjects];
}



-(void)startSvc:(NSDictionary*)params reply:(void(^)(NSString*))reply
{
    if(self.state != MESHER_STATE_STOP)
    {
        return;
    }
    
    _param = params;
    
    self.state = MESHER_STATE_PUBLISHING;
    [self publishLocalMesher];
}

-(void)publishLocalMesher
{
    // create new instance of netService
 	_myMesherService = [[NSNetService alloc] initWithDomain:@""
                                                       type:MESHER_SERVICE_TYPE
                                                       name:MESHER_SERVICE_NAME
                                                       port:(self.servicePort==0)?4001:self.servicePort];
	if (_myMesherService == nil)
    {
        [NSException raise:@"alloc Mesher Failed!" format:@"there is an exception raise in func publishLocalMesher"];
    }
    
    // Add service to current run loop
	[_myMesherService scheduleInRunLoop:[NSRunLoop currentRunLoop]
                                forMode:NSRunLoopCommonModes];
    
    // NetService will let us know about what's happening via delegate methods
	[_myMesherService setDelegate:self];
    
    // Publish the service
	[_myMesherService publish];
}


-(void)joinLocalMesher:(int) index
{
    if(index >= [_allMesherServices count])
    {
        self.state = MESHER_STATE_ERROR;
        return;
    }
    
    NSNetService* service = [_allMesherServices objectAtIndex:index];
    if(service.hostName == nil)
    {
        service.delegate  = self;
        [service resolveWithTimeout:5.0];
        self.state = MESHER_STATE_JOINING;
    }
    else
    {
        self.mesherName = service.hostName;
        self.state = MESHER_STATE_JOINED;
    }
}

-(void)stopSvc
{
    [_etcdManager stopETCD];
    [self stopBrowser];
    [self unpublishLocalMesher];
    self.mesherName = @"";
    
    self.state = MESHER_STATE_STOP;
}

- (void) unpublishLocalMesher
{
    if (_myMesherService)
    {
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
    // Make sure that we don't have such service already (why would this happen? not sure)
    if ( ![_allMesherServices containsObject:netService] )
    {
        // Add it to our list
        [_allMesherServices addObject:netService];
    }
    
    // If more entries are coming, no need to update UI just yet
    if ( moreServicesComing )
    {
        return;
    }
}


// Service was removed
- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser
         didRemoveService:(NSNetService *)netService
               moreComing:(BOOL)moreServicesComing
{
    // Remove from list
    [_allMesherServices removeObject:netService];
    
    // If more entries are coming, no need to update UI just yet
    if ( moreServicesComing )
    {
        return;
    }
}

// Called when net service has been successfully resolved
- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
    NSLog(@"service:%@ can be resloved, hostname:%@, port:%ld\n", sender.name, sender.hostName, (long)sender.port);
    
    self.mesherName = sender.hostName;
    
    self.state = MESHER_STATE_JOINED;
}

#pragma mark -
#pragma mark NSNetService Delegate Method Implementations

// Delegate method, called by NSNetService in case service publishing fails for whatever reason
- (void) netService:(NSNetService*)sender didNotPublish:(NSDictionary*)errorDict
{
    if ( sender != _myMesherService )
    {
        return;
    }
    
    //goto JoinMesher State
    [self joinLocalMesher:0];
}

- (void) netServiceDidPublish:(NSNetService *)sender
{
    self.state = MESHER_STATE_PUBLISHED;
    self.mesherName = [[NSHost currentHost] name];
    
    [_etcdManager startETCD:_param];;
    NSLog(@" >> netServiceDidPublish: %@", [sender name]);
}

- (void) netServiceDidStop:(NSNetService *)sender
{
    NSLog(@" >> netServiceDidStop: %@", [sender name]);
}

// Called if we weren't able to resolve net service
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
    NSLog(@"service:%@ can not be resloved!\n", sender.name);
    self.state = MESHER_STATE_ERROR;
}



@end
