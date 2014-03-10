//
//  AMMesher.m
//  AMMesher
//
//  Created by Wei Wang on 3/10/14.
//  Copyright (c) 2014 Wei Wang. All rights reserved.
//

#import "AMMesher.h"
#import "AMETCDApi/AMETCD.h"

#pragma mark -
#pragma mark NSNetService (BrowserViewControllerAdditions)

// A category on NSNetService that's used to sort NSNetService objects by their name.
@interface NSNetService (BrowserViewControllerAdditions)

- (NSComparisonResult) localizedCaseInsensitiveCompareByName:(NSNetService *)aService;

@end

@implementation NSNetService (BrowserViewControllerAdditions)

- (NSComparisonResult) localizedCaseInsensitiveCompareByName:(NSNetService *)aService
{
	return [[self name] localizedCaseInsensitiveCompare:[aService name]];
}

@end


@implementation AMMesher
{
    NSNetServiceBrowser*  _netServiceBrowser;
    NSNetService* _myMesher;
    AMETCD* _etcd;
    
    int _servicePort;
}


-(id)init
{
    if(self = [super init])
    {
        self.meshers = [[NSMutableArray alloc]init];
        self.mesherState = MESHER_STATE_STOP;
    
        _servicePort = 7001;
    }
    
    return self;
}

-(BOOL)start
{
    if(self.mesherState >= MESHER_STATE_START)
    {
        return NO;
    }
    
    if(![self browseLocalMesher])
    {
        return NO;
    }
    
    self.mesherState = MESHER_STATE_START;
    
    return YES;
}

-(void)stop
{
    [self stopBrowser];
    [self unpublishLocalMesher];
    [self stopETCD];
    
    self.mesherState = MESHER_STATE_STOP;
}


-(BOOL)browseLocalMesher
{
    if(self.mesherState != MESHER_STATE_START)
    {
        return NO;
    }
    
    if(_netServiceBrowser != nil)
    {
        [self stopBrowser];
    }
    
    _netServiceBrowser = [[NSNetServiceBrowser alloc] init];
    if(!_netServiceBrowser)
    {
        return NO;
    }
    
    _netServiceBrowser.delegate = self;
    [_netServiceBrowser searchForServicesOfType:@"_artsmesh._tcp" inDomain:@""];
    
    return YES;
}


// Terminate current service browser and clean up
- (void) stopBrowser
{
    if (_netServiceBrowser == nil )
    {
        return;
    }
    
    [_netServiceBrowser stop];
    _netServiceBrowser = nil;
    
    [self.meshers removeAllObjects];
}


-(void)stopETCD
{
    if(_etcd)
    {
        [_etcd stopETCD];
        _etcd  = nil;
    }
}

-(void)startETCD:(NSString*)hostAddr;
{
    _etcd = [[AMETCD alloc] init];
    _etcd.leaderAddr = hostAddr;
    
    [_etcd startETCD];
    
    _servicePort = _etcd.serverPort;
}


-(BOOL)joinLocalMesher:(int) index
{
    if(self.mesherState < MESHER_STATE_START)
    {
        return NO;
    }
    
    if(index >= [self.meshers count])
    {
        return NO;
    }
    
    if(self.mesherState == MESHER_STATE_HOSTING)
    {
        [self unpublishLocalMesher];
        [self stopETCD];
    }
    else if(self.mesherState == MESHER_STATE_JOINED)
    {
        [self stopETCD];
    }
    
    self.mesherState = MESHER_STATE_START;
    
    NSNetService* service = [self.meshers objectAtIndex:index];
    
    NSString* leaderAddr = [NSString stringWithFormat:@"%@:%ld", service.hostName, (long)service.port];
    [self startETCD:leaderAddr];
    
    _servicePort = _etcd.serverPort;
    self.mesherState = MESHER_STATE_JOINED;

    return YES;
}


-(BOOL)publishLocalMesher
{
    if(self.mesherState < MESHER_STATE_START)
    {
        return NO;
    }
    
    if(self.mesherState == MESHER_STATE_JOINED)
    {
        [self stopETCD];
    }
    else if(self.mesherState == MESHER_STATE_HOSTING)
    {
        [self unpublishLocalMesher];
        [self stopETCD];
    }
    
    self.mesherState = MESHER_STATE_START;
  
    [self startETCD:nil];
    
    NSHost* host = [NSHost currentHost];
    NSString* mesherName = [NSString stringWithFormat:@"%@'s mesher", [host name]];
    
    // create new instance of netService
 	_myMesher = [[NSNetService alloc] initWithDomain:@""
                                                type:@"_artsmesh._tcp."
                                                name:mesherName
                                                port:_servicePort];
	if (_myMesher == nil)
    {
        [self stopETCD];
        self.mesherState = MESHER_STATE_START;
        return NO;
    }
    
    // Add service to current run loop
	[_myMesher scheduleInRunLoop:[NSRunLoop currentRunLoop]
                         forMode:NSRunLoopCommonModes];
    
    // NetService will let us know about what's happening via delegate methods
	[_myMesher setDelegate:self];
    
    // Publish the service
	[_myMesher publish];
    
    self.mesherState = MESHER_STATE_HOSTING;
    return YES;
}

- (void) unpublishLocalMesher
{
    if(self.mesherState != MESHER_STATE_HOSTING)
    {
        return;
    }
    
    if (_myMesher)
    {
		[_myMesher stop];
		[_myMesher removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
		_myMesher = nil;
	}
}


// Sort servers array by service names
- (void) sortServers
{
    [self.meshers sortUsingSelector:@selector(localizedCaseInsensitiveCompareByName:)];
}


#pragma mark -
#pragma mark NSNetServiceBrowser Delegate Method Implementations

// New service was found
- (void) netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser
            didFindService:(NSNetService *)netService
                moreComing:(BOOL)moreServicesComing
{
    // Make sure that we don't have such service already (why would this happen? not sure)
    if ( ! [self.meshers containsObject:netService] ) {
        // Add it to our list
        [self.meshers addObject:netService];
    }
    
    // If more entries are coming, no need to update UI just yet
    if ( moreServicesComing ) {
        return;
    }
    
    // Sort alphabetically and let our delegate know
    [self sortServers];
    
    [self.delegate updateServerList];
}


// Service was removed
- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser
         didRemoveService:(NSNetService *)netService
               moreComing:(BOOL)moreServicesComing
{
    // Remove from list
    [self.meshers removeObject:netService];
    
    // If more entries are coming, no need to update UI just yet
    if ( moreServicesComing ) {
        return;
    }
    
    // Sort alphabetically and let our delegate know
    [self sortServers];
    
    [self.delegate updateServerList];
}

#pragma mark -
#pragma mark NSNetService Delegate Method Implementations

// Delegate method, called by NSNetService in case service publishing fails for whatever reason
- (void) netService:(NSNetService*)sender didNotPublish:(NSDictionary*)errorDict
{
    if ( sender != _myMesher )
    {
        return;
    }
    
    // Stop etcd
    [_etcd stopETCD];
    _etcd = nil;
    
    // Stop Bonjour
    [self unpublishLocalMesher];
    
    // Let delegate know about failure
    //[delegate serverFailed:self reason:@"Failed to publish service via Bonjour (duplicate server name?)"];
}

- (void) netServiceDidPublish:(NSNetService *)sender
{
    NSLog(@" >> netServiceDidPublish: %@", [sender name]);
}

- (void) netServiceDidStop:(NSNetService *)sender
{
    NSLog(@" >> netServiceDidStop: %@", [sender name]);
}

@end
