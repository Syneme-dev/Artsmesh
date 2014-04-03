//
//  AMLaunchETCDOperation.m
//  AMMesher
//
//  Created by Wei Wang on 3/30/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMLaunchETCDOperation.h"
#import "AMNetworkUtils/AMNetworkUtils.h"
#import "AMETCDApi/AMETCD.h"

@implementation AMLaunchETCDOperation
{
    NSMutableArray*  _parameters;
    AMETCD* _etcdAPi;
}

-(id)initWithParameter:(NSString*)hostAddr
            serverPort:(NSString*)sp
            clientPort:(NSString*)cp
                 peers:(NSString*)peers
     heartbeatInterval:(NSString*)hbInterval
       electionTimeout:(NSString*)elecTimeout
              delegate:(id<AMMesherOperationProtocol>)delegate
{
    if (self = [super init])
    {
        _parameters = [[NSMutableArray alloc] init];
        
        NSString* peer_addr = [NSString stringWithFormat:@"%@:%@", hostAddr, sp];
        [_parameters addObject:@"-peer-addr"];
        [_parameters addObject:peer_addr];
        
        NSString* addr = [NSString stringWithFormat:@"%@:%@", hostAddr, cp];
        [_parameters addObject:@"-addr"];
        [_parameters addObject:addr];
        
        NSString* hostName = [AMNetworkUtils getHostName];
        NSString* tempPath = NSTemporaryDirectory();
        NSString* curTime = [AMNetworkUtils getCurrentTimeString];
        NSString* data_dir = [tempPath stringByAppendingPathComponent:
                               [NSString stringWithFormat:@"%@-%@", hostName, curTime]];
        [_parameters addObject:@"-data-dir"];
        [_parameters addObject:data_dir];
        
        [_parameters addObject:@"-name"];
        [_parameters addObject:hostName];
        
        [_parameters addObject:@"-peer-heartbeat-timeout"];
        [_parameters addObject:hbInterval];
        
        [_parameters addObject:@"-peer-election-timeout"];
        [_parameters addObject:elecTimeout];
        
        if (peers != nil && ![peers isEqualToString:@""])
        {
            [_parameters addObject:@"-peers"];
            [_parameters addObject:peers];
        }
        
        _etcdAPi = [[AMETCD alloc] init];
        _etcdAPi.serverIp = hostAddr;
        _etcdAPi.clientPort = [cp intValue];
        _etcdAPi.serverPort = [sp intValue];
        
        _isResultOK = NO;
        self.delegate = delegate;
    }
    
    return self;
}

-(void)main
{
    NSLog(@"AMETCD launching...");
    
    if (self.isCancelled) { return; }
    
    [NSTask launchedTaskWithLaunchPath:@"/usr/bin/killall"
                             arguments:[NSArray arrayWithObjects:@"-c", @"etcd", nil]];
    usleep(1000*500);
    
    NSTask* etcdTask = [[NSTask alloc] init];
    NSBundle* mainBundle = [NSBundle mainBundle];
    etcdTask.launchPath = [mainBundle pathForAuxiliaryExecutable:@"etcd"];
    
    etcdTask.arguments = _parameters;
    [etcdTask launch];

    usleep(1000*100);

    int retry = 0;
    for (; retry < 10; retry++)
    {
        if (self.isCancelled) { return; }
        
        AMETCDResult* res = [_etcdAPi setKey:@"/ready" withValue:@"yes" ttl:100];
        if(res != nil && res.errCode == 0)
        {
            _isResultOK = YES;
            break;
        }
        
        usleep(1000*100);
    }
    
    if (retry == 10)
    {
        _isResultOK = NO;
    }
    
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(LanchETCDOperationDidFinish:) withObject:self waitUntilDone:NO];
}

@end
