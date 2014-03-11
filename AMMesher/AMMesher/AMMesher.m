//
//  AMMesher.m
//  AMMesher
//
//  Created by Wei Wang on 3/10/14.
//  Copyright (c) 2014 Wei Wang. All rights reserved.
//

#import "AMMesher.h"


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
    NSMutableArray* _meshers;
    AMETCD* _etcd;
    
    int _servicePort;
}


-(id)init
{
    if(self = [super init])
    {
        _meshers = [[NSMutableArray alloc]init];
        self.state = MESHER_STATE_STOP;
        
        [self browseLocalMesher];
        _servicePort = 7001;
        
        [AMETCD clearETCD];
    }
    
    return self;
}

-(void)dealloc
{
    [self stop];
}

-(BOOL)start
{
    if(self.state != MESHER_STATE_STOP)
    {
        return NO;
    }
    
    self.state = MESHER_STATE_PUBLISHING;
    [self publishLocalMesher];
    
    return YES;

}

-(void)stop
{
    [self stopBrowser];
    [self unpublishLocalMesher];
    self.mesherName = @"";
    
    self.state = MESHER_STATE_STOP;
}


-(AMETCD*)getETCDRef
{
    return _etcd;
}


-(BOOL)browseLocalMesher
{
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
    [_netServiceBrowser searchForServicesOfType:@"_artsmesh._tcp." inDomain:@""];
    
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
    
    [_meshers removeAllObjects];
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
    if(_etcd == nil)
    {
        _etcd = [[AMETCD alloc] init];
        _etcd.leaderAddr = hostAddr;
        
        [_etcd startETCD];
        
        _servicePort = _etcd.serverPort;
    }
}


-(BOOL)joinLocalMesher:(int) index
{
    if(index >= [_meshers count])
    {
        return NO;
    }
    
    NSNetService* service = [_meshers objectAtIndex:index];
    NSString* leaderAddr = [NSString stringWithFormat:@"%@:%ld", service.hostName, (long)service.port];
    [self startETCD:leaderAddr];
    
    self.mesherName = service.hostName;

    return YES;
}


-(BOOL)publishLocalMesher
{
    // create new instance of netService
 	_myMesher = [[NSNetService alloc] initWithDomain:@""
                                                type:@"_artsmesh._tcp."
                                                name:@"Artsmesh-Mesher-Service"
                                                port:_servicePort];
	if (_myMesher == nil)
    {
        [NSException raise:@"alloc Mesher Failed!" format:@"there is an exception raise in func publishLocalMesher"];
    }
    
    // Add service to current run loop
	[_myMesher scheduleInRunLoop:[NSRunLoop currentRunLoop]
                         forMode:NSRunLoopCommonModes];
    
    // NetService will let us know about what's happening via delegate methods
	[_myMesher setDelegate:self];
    
    // Publish the service
	[_myMesher publish];
    
    //[self startETCD:nil];
    
    return YES;
}

- (void) unpublishLocalMesher
{
    if (_myMesher)
    {
		[_myMesher stop];
		[_myMesher removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
		_myMesher = nil;
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
    if ( ! [_meshers containsObject:netService] ) {
        // Add it to our list
        [netService resolveWithTimeout:5.0];
    }
    
    // If more entries are coming, no need to update UI just yet
    if ( moreServicesComing ) {
        return;
    }
}


// Service was removed
- (void)netServiceBrowser:(NSNetServiceBrowser *)netServiceBrowser
         didRemoveService:(NSNetService *)netService
               moreComing:(BOOL)moreServicesComing
{
    // Remove from list
    [_meshers removeObject:netService];
    
    // If more entries are coming, no need to update UI just yet
    if ( moreServicesComing ) {
        return;
    }
    
    if(YES == [self joinLocalMesher:0])
    {
        self.state = MESHER_STATE_JOINED;
    }
    else
    {
        self.state = MESHER_STATE_PUBLISHING;
        [self publishLocalMesher];
    }
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
    
    if(YES == [self joinLocalMesher:0])
    {
        self.state = MESHER_STATE_JOINED;
    }
    else
    {
        self.state = MESHER_STATE_ERROR;
    }
}

- (void) netServiceDidPublish:(NSNetService *)sender
{
    [self startETCD:nil];
    self.state = MESHER_STATE_PUBLISHED;
    self.mesherName = [[NSHost currentHost] name];
    
    NSLog(@" >> netServiceDidPublish: %@", [sender name]);
}

- (void) netServiceDidStop:(NSNetService *)sender
{
    self.state = MESHER_STATE_STOP;
    
    NSLog(@" >> netServiceDidStop: %@", [sender name]);
}

// Called if we weren't able to resolve net service
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
    NSLog(@"service:%@ can not be resloved!\n", sender.name);
}


// Called when net service has been successfully resolved
- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
    NSLog(@"service:%@ can be resloved, hostname:%@, port:%ld\n", sender.name, sender.hostName, (long)sender.port);
    [_meshers addObject:sender];
}


@end
