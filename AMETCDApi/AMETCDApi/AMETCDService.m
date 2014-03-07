//
//  AMETCDApi.m
//  HttpAndJson
//
//  Created by 王 为 on 2/27/14.
//  Copyright (c) 2014 王 为. All rights reserved.
//

#import "AMETCDService.h"

@implementation AMETCDService
{
    NSTask* _etcdTask;
}


-(id)init
{
    if(self = [super init])
    {
        NSHost* host = [NSHost currentHost];
        self.nodeIp = [host address];
        self.serverPort = 7001;
        self.clientPort = 4001;
        self.leaderAddr = nil;
        
        self.nodeName = [host name];
    }
    
    return self;
}


-(BOOL)startETCD
{
    if(_etcdTask != nil)
    {
        return YES;
    }
    
    _etcdTask = [[NSTask alloc] init];
//    NSBundle* mainBundle = [NSBundle mainBundle];
//    _etcdTask.launchPath = [mainBundle pathForAuxiliaryExecutable:@"etcd"];
    
    _etcdTask.launchPath = @"/usr/bin/etcd";
    
    NSString* peerAddr = [NSString stringWithFormat:@"%@:%d", self.nodeIp, self.serverPort];
    NSString* addr = [NSString stringWithFormat:@"%@:%d", self.nodeIp, self.clientPort];
    NSString* dataDir = self.nodeName;
    NSString* etcdName = self.nodeName;
    
    NSString* leaderAddr;
    if(self.leaderAddr != nil)
    {
        leaderAddr = [NSString stringWithFormat:@"-peers:%@", self.leaderAddr];
    }
    else
    {
        leaderAddr = @"";
    }
    
    NSString* args = [NSString stringWithFormat:@" -peer-addr %@ -addr %@ -data-dir %@ -name %@ %@", peerAddr, addr, dataDir, etcdName, leaderAddr];
    
    _etcdTask.arguments = @[args];
    [_etcdTask launch];

    
    return YES;
}


-(void)stopETCD
{
    [_etcdTask terminate];
    [_etcdTask waitUntilExit];
    
    [NSTask launchedTaskWithLaunchPath:@"/usr/bin/killall"
                             arguments:[NSArray arrayWithObjects:@"-c", @"etcd", nil]];
    
    sleep(1);
    _etcdTask = nil;
}


-(AMETCDCURDResult*)getKey:(NSString*)key
{
    NSString* urlStr  = [NSString stringWithFormat:@"http://%@:%d/v2/keys%@",
                         self.nodeIp,
                         self.clientPort,
                         key];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"GET"];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil error:nil];
    
    NSString* resultLog = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"%@\n", resultLog);
    
    AMETCDCURDResult* result = [[AMETCDCURDResult alloc] initWithData:returnData];
    return result;
}


-(AMETCDCURDResult*)setKey:(NSString*)key withValue:(NSString*)value;
{
    NSString* headerfield = @"application/x-www-form-urlencoded";
    NSString* urlStr  = [NSString stringWithFormat:@"http://%@:%d/v2/keys%@",
                         self.nodeIp,
                         self.clientPort,
                         key];
    NSMutableData* httpBody = [self createSetKeyHttpBody:@"value" withValue:value];
    NSMutableDictionary* headerDictionary = [[NSMutableDictionary alloc] init];
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"PUT"];
    [request addValue:headerfield forHTTPHeaderField:@"Content-Type"];
    [request setAllHTTPHeaderFields:headerDictionary];
    [request setHTTPBody: httpBody];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil error:nil];
    
    //Log will remove
    NSString* resultLog = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"%@\n", resultLog);


    return [[AMETCDCURDResult alloc] initWithData:returnData];
    
}



-(AMETCDCURDResult*)watchKey:(NSString*)key
                   fromIndex:(int)index_in
                acturalIndex:(int*)index_out
                     timeout:(int)seconds

{
    
   // http://127.0.0.1:4001/v2/keys/foo?wait=true&waitIndex=7'

    NSString* headerfield = @"application/x-www-form-urlencoded";
    NSString* urlStr  = [NSString stringWithFormat:@"http://%@:%d/v2/keys%@?wait=true&waitIndex=%d",
                         self.nodeIp,
                         self.clientPort,
                         key,
                         index_in];
    NSMutableDictionary* headerDictionary = [[NSMutableDictionary alloc] init];

    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"GET"];
    [request addValue:headerfield forHTTPHeaderField:@"Content-Type"];
    [request setAllHTTPHeaderFields:headerDictionary];
    
    if(seconds == 0)
    {
        [request setTimeoutInterval: 3600];
    }
    else
    {
        [request setTimeoutInterval:seconds];
    }
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil error:nil];
    
    //Log will remove
    NSString* resultLog = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"%@\n", resultLog);
    
    AMETCDCURDResult* result = [[AMETCDCURDResult alloc] initWithData:returnData];
    
    if(result != nil && result.node != nil)
    {
        *index_out = result.node.createdIndex;
    }
    else
    {
        *index_out = -1;
    }
    
    return result;
}


-(AMETCDCURDResult*)deleteKey: (NSString*) key
{
    //curl -L http://127.0.0.1:4001/v2/keys/message -XDELETE
    NSString* urlStr  = [NSString stringWithFormat:@"http://%@:%d/v2/keys%@",
                         self.nodeIp,
                         self.clientPort,
                         key];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"DELETE"];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil error:nil];
    
    NSString* resultLog = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"%@\n", resultLog);
    
    AMETCDCURDResult* result = [[AMETCDCURDResult alloc] initWithData:returnData];
    return result;
    
}


-(NSMutableData*)createSetKeyHttpBody: (NSString*)key withValue:(NSString*)val
{
    NSMutableData* body = [NSMutableData data];
    
    key = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    key = [key stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    key = [key stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    val = [val stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    val = [val stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    val = [val stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    [body appendData:[[NSString stringWithFormat:@"%@=%@", key, val] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return body;
}


@end
