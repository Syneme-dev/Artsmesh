//
//  AMETCDLaunchOperation.m
//  AMMesher
//
//  Created by 王 为 on 4/9/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDLaunchOperation.h"
#import "AMNetworkUtils/AMNetworkUtils.h"
#import "AMETCDApi/AMETCD.h"
#import "AMETCDOperationDelegate.h"

@implementation AMETCDLaunchOperation

-(id)initWithParameter:(NSString*)ip
            clientPort:(NSString*)cp
            serverPort:(NSString*)sp
                 peers:(NSString*)peers
     heartbeatInterval:(NSString*)hbInterval
       electionTimeout:(NSString*)elecTimeout
{
    if (self = [super init:ip port:cp])
    {
        self.parameters = [[NSMutableArray alloc] init];
        
        NSString* peer_addr = [NSString stringWithFormat:@"%@:%@", ip, sp];
        [self.parameters addObject:@"-peer-addr"];
        [self.parameters addObject:peer_addr];
        
        NSString* addr = [NSString stringWithFormat:@"%@:%@", ip, cp];
        [self.parameters addObject:@"-addr"];
        [self.parameters addObject:addr];
        
        NSString* hostName = [AMNetworkUtils getHostName];
        NSString* tempPath = NSTemporaryDirectory();
        NSString* curTime = [AMNetworkUtils getCurrentTimeString];
        NSString* data_dir = [tempPath stringByAppendingPathComponent:
                              [NSString stringWithFormat:@"%@-%@", hostName, curTime]];
        [self.parameters addObject:@"-data-dir"];
        [self.parameters addObject:data_dir];
        
        [self.parameters addObject:@"-name"];
        [self.parameters addObject:hostName];
        
        [self.parameters addObject:@"-peer-heartbeat-timeout"];
        [self.parameters addObject:hbInterval];
        
        [self.parameters addObject:@"-peer-election-timeout"];
        [self.parameters addObject:elecTimeout];
        
        if (peers != nil && ![peers isEqualToString:@""])
        {
            [self.parameters addObject:@"-peers"];
            [self.parameters addObject:peers];
        }
        
        self.etcdApi.serverPort = sp;
        self.operationType = @"lanuch";
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
        
        AMETCDResult* res = [self.etcdApi setKey:@"/ready" withValue:@"yes" ttl:100];
        if(res != nil && res.errCode == 0)
        {
            self.isResultOK = YES;
            break;
        }
        
        usleep(1000*100);
    }
    
    if (retry == 10)
    {
        self.isResultOK = NO;
    }
    
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AMETCDOperationDidFinished:) withObject:self waitUntilDone:NO];
}



@end
