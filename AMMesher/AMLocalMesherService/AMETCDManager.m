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

-(void)startService:(NSDictionary*)params reply:(void(^)(NSString*))reply
{
    if(_etcdTask != nil)
    {
        return;
    }
    
    _etcdTask = [[NSTask alloc] init];
    NSBundle* mainBundle = [NSBundle mainBundle];
    _etcdTask.launchPath = [mainBundle pathForAuxiliaryExecutable:@"etcd"];
    
    
    NSString* tempPath = NSTemporaryDirectory();
    NSString* curTime = [AMNetworkUtils getCurrentTimeString];
    NSString* hostName = [AMNetworkUtils getHostName];
    NSString* etcdDataDir = [tempPath stringByAppendingPathComponent:
                             [NSString stringWithFormat:@"%@-%@", hostName, curTime]];
    
    id serverPort = [params objectForKey:@"etcdServrePort"];
    id clientPort = [params objectForKey:@"etcdClientPort"];
    
    int isport;
    int icport;
    if(serverPort == nil)
    {
        isport = 7001;
    }
    else
    {
        isport = [serverPort intValue];
    }
    
    if(clientPort == nil)
    {
        icport = 4001;
    }
    else
    {
        icport = [clientPort  intValue];
    }
    
    
    NSArray* argArry = [NSArray arrayWithObjects:
                        @"-peer-addr", [NSString stringWithFormat:@"%@:%d", [AMNetworkUtils getHostIpv4Addr], isport],
                        @"-addr", [NSString stringWithFormat:@"%@:%d", [AMNetworkUtils getHostIpv4Addr], icport],
                        @"-data-dir", etcdDataDir,
                        @"-name", hostName,
                        nil];
    
    _etcdTask.arguments = argArry;
    [_etcdTask launch];
}

-(void)stopService
{
    [NSTask launchedTaskWithLaunchPath:@"/usr/bin/killall"
                             arguments:[NSArray arrayWithObjects:@"-c", @"etcd", nil]];
    sleep(1);
    _etcdTask = nil;
}

-(void)clearAllData
{
    NSString *imageDir = [NSString stringWithFormat:@"%@", [NSHost currentHost].name];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:imageDir error:nil];
}

@end
