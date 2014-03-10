//
//  AMMesher.m
//  AMMesher
//
//  Created by Wei Wang on 3/10/14.
//  Copyright (c) 2014 Wei Wang. All rights reserved.
//

#import "AMMesher.h"
//#import "AMETCD/AMETCD.h"

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
}


-(id)init
{
    if(self = [super init])
    {
        self.meshers = [[NSMutableArray alloc]init];
    }
    
    return self;
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
    [_netServiceBrowser searchForServicesOfType:@"AMMesherServer._tcp" inDomain:@""];
    
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


-(void)joinLocalMesher:(NSString*) mesherName
{
    for (NSNetService* service in self.meshers)
    {
        if([service.name isEqualToString:mesherName])
        {
            //NSString* mesherIp
            //port
            //set leaderaddress
            //client port
            //serverport
            //start etcd
        }
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


@end
