//
//  AMMesher.m
//  AMMesher
//
//  Created by Wei Wang on 3/10/14.
//  Copyright (c) 2014 Wei Wang. All rights reserved.
//

#import "AMMesher.h"
#include <sys/socket.h>
#include <netinet/in.h>

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
    
    int _myServicePort;
    NSString* _myServiceIp;
}

+ (BOOL)isValidIpv4:(NSString *)ip {
    const char *utf8 = [ip UTF8String];
    
    // Check valid IPv4.
    struct in_addr dst;
    int success = inet_pton(AF_INET, utf8, &(dst.s_addr));
    return (success == 1);
}


+ (BOOL)isValidIpv6:(NSString *)ip {
    const char *utf8 = [ip UTF8String];
    
    // Check valid IPv6.
    struct in6_addr dst6;
    int success = inet_pton(AF_INET6, utf8, &dst6);
    
    return (success == 1);
}


+(NSString*)getIpv4Addr
{
    NSHost* host = [NSHost currentHost];
    for(NSString* addr in host.addresses)
    {
        if([AMMesher isValidIpv4:addr])
        {
            if(![addr isEqualToString:@"127.0.0.1"])
            {
                return addr;
            }
        }
    }
    
    return nil;
}


+(NSString*)getIpv6Addr
{
    NSHost* host = [NSHost currentHost];
    for(NSString* addr in host.addresses)
    {
        if([AMMesher isValidIpv6:addr])
        {
            if(![addr isEqualToString:@"::1"])
            {
                return addr;
            }
        }
    }
    
    return nil;
}


-(id)init
{
    if(self = [super init])
    {
        _meshers = [[NSMutableArray alloc]init];
        self.state = MESHER_STATE_STOP;
        
        [self browseLocalMesher];
        _myServicePort = 7001;
        _myServiceIp = [AMMesher getIpv4Addr];
        
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
    
    [self stopETCD];
    
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
        _etcd.nodeIp = _myServiceIp;
        _etcd.clientPort = 4001;
        _etcd.serverPort = 7001;
        
        [_etcd startETCD];

    }
}


-(BOOL)joinLocalMesher:(int) index
{
    if(index >= [_meshers count])
    {
        return NO;
    }
    
    NSNetService* service = [_meshers objectAtIndex:index];
    if(service.hostName == nil)
    {
        service.delegate  = self;
        [service resolveWithTimeout:5.0];
        self.state = MESHER_STATE_JOINING;
    }
    else
    {
        NSString* leaderAddr = [NSString stringWithFormat:@"%@:%ld", service.hostName, (long)service.port];
        [self startETCD:leaderAddr];
        
        self.mesherName = service.hostName;
    }
    
    return YES;
}


-(BOOL)publishLocalMesher
{
    // create new instance of netService
 	_myMesher = [[NSNetService alloc] initWithDomain:@""
                                                type:@"_artsmesh._tcp."
                                                name:@"artsmesh-mesher-service"
                                                port:7001];
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
        [_meshers addObject:netService];
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

    [self joinLocalMesher:0];
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
    NSLog(@" >> netServiceDidStop: %@", [sender name]);
}

// Called if we weren't able to resolve net service
- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
    NSLog(@"service:%@ can not be resloved!\n", sender.name);
    self.state = MESHER_STATE_ERROR;
}


// Called when net service has been successfully resolved
- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
    NSLog(@"service:%@ can be resloved, hostname:%@, port:%ld\n", sender.name, sender.hostName, (long)sender.port);
    
    char addressBuffer[INET6_ADDRSTRLEN];
    
    for (NSData *data in sender.addresses)
    {
        memset(addressBuffer, 0, INET6_ADDRSTRLEN);
        
        typedef union {
            struct sockaddr sa;
            struct sockaddr_in ipv4;
            struct sockaddr_in6 ipv6;
        } ip_socket_address;
        
        ip_socket_address *socketAddress = (ip_socket_address *)[data bytes];
        
        if (socketAddress && (socketAddress->sa.sa_family == AF_INET || socketAddress->sa.sa_family == AF_INET6))
        {
            const char *addressStr = inet_ntop(
                                               socketAddress->sa.sa_family,
                                               (socketAddress->sa.sa_family == AF_INET ? (void *)&(socketAddress->ipv4.sin_addr) : (void *)&(socketAddress->ipv6.sin6_addr)),
                                               addressBuffer,
                                               sizeof(addressBuffer));
            
            //int port = ntohs(socketAddress->sa.sa_family == AF_INET ? socketAddress->ipv4.sin_port : socketAddress->ipv6.sin6_port);
            
            NSString* hostIp = [NSString stringWithCString:addressBuffer encoding:NSUTF8StringEncoding];
            if([AMMesher isValidIpv4:hostIp])
            {
                //ipv4
                NSString* leaderAddr = [NSString stringWithFormat:@"%@:%ld", hostIp, (long)sender.port];
                [self startETCD:leaderAddr];
                
                self.mesherName = sender.hostName;
                self.state = MESHER_STATE_JOINED;
                return;
            }
        }
    }
    
    self.state = MESHER_STATE_ERROR;
}


@end
