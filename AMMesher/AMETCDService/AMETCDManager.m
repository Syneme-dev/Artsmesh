//
//  AMETCDManager.m
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDManager.h"
#import "AMNetworkUtils/AMNetworkUtils.h"

@implementation AMETCDManager
{
    NSTask* _etcdTask;
}

-(void)startService:(NSDictionary*)params reply:(void (^)(id))reply;
{
    [self stopService];
    
    _etcdTask = [[NSTask alloc] init];
    NSBundle* mainBundle = [NSBundle mainBundle];
    _etcdTask.launchPath = [mainBundle pathForAuxiliaryExecutable:@"etcd"];
    
    NSString* tempPath = NSTemporaryDirectory();
    NSString* curTime = [AMNetworkUtils getCurrentTimeString];
    NSString* hostName = [AMNetworkUtils getHostName];

    
    NSString* _peer_addr = [params objectForKey:@"-peer-addr"];
    NSString* _addr = [params objectForKey:@"-addr"];
    NSString* _name = [NSString stringWithFormat:@"%@", hostName];
    NSString* _data_dir = [tempPath stringByAppendingPathComponent:
                           [NSString stringWithFormat:@"%@-%@", hostName, curTime]];
    NSString* _peers = [params objectForKey:@"-peers"];
    NSString* _peer_heartbeat_interval = [params objectForKey:@"-peer-heartbeat-interval"];
    NSString* _peer_election_timeout = [params objectForKey:@"-peer-election-timeout"];
    
    
    if(_peer_addr == nil)
    {
        _peer_addr = [NSString stringWithFormat:@"%@:%d", [AMNetworkUtils getHostIpv4Addr], 7001];
    }
    
    if(_addr == nil)
    {
        _addr = [NSString stringWithFormat:@"%@:%d", [AMNetworkUtils getHostIpv4Addr], 4001];
    }
    
    
    NSMutableArray* paramsArry = [[NSMutableArray alloc] init];
    
    [paramsArry addObject:@"-peer-addr"];
    [paramsArry addObject:_peer_addr];
    
    [paramsArry addObject:@"-addr"];
    [paramsArry addObject:_addr];

    [paramsArry addObject:@"-data-dir"];
    [paramsArry addObject:_data_dir];

    [paramsArry addObject:@"-name"];
    [paramsArry addObject:_name];
    
    if(_peer_heartbeat_interval)
    {
        [paramsArry addObject:@"-peer-heartbeat-interval"];
        [paramsArry addObject:_peer_heartbeat_interval];
    }

    if(_peer_election_timeout)
    {
        [paramsArry addObject:@"-peer-election-timeout"];
        [paramsArry addObject:_peer_election_timeout];
    }
    
    if (_peers)
    {
        [paramsArry addObject:@"-peers"];
        [paramsArry addObject:_peers];
    }

    _etcdTask.arguments = paramsArry;
    [_etcdTask launch];
    
    reply(nil);
}

-(void)stopService
{
    [NSTask launchedTaskWithLaunchPath:@"/usr/bin/killall"
                             arguments:[NSArray arrayWithObjects:@"-c", @"etcd", nil]];
    sleep(1);
    _etcdTask = nil;
}

@end
