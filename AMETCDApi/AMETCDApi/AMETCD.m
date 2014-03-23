//
//  AMETCDApi.m
//  HttpAndJson
//
//  Created by 王 为 on 2/27/14.
//  Copyright (c) 2014 王 为. All rights reserved.
//

#import "AMETCD.h"
#include <sys/socket.h>
#include <netinet/in.h>

@implementation AMETCD
{
}

-(id)initWithService:(NSString*)serverIP port:(int)port
{
    if(self = [super init])
    {
        self.serverIp = serverIP;
        self.serverPort = port;
    }
    
    return self;
}



-(NSString*)rootKey
{
    return [NSString stringWithFormat:@"http://%@:%d/v2/keys",
                         self.serverIp,
                         self.serverPort];
}


-(NSMutableString*)getRequestURL:(NSString*)key withParams: (NSString*)params
{
    NSMutableString* requestURL = [NSMutableString stringWithString:[self rootKey]];
    
    if ([key hasPrefix:@"/"])
    {
        [requestURL appendString:key];
    }
    else
    {
        [requestURL appendString:@"/"];
        [requestURL appendString:key];
    }
    
    if (params != nil)
    {
        [requestURL appendString:@"?"];
        [requestURL appendString:params];
    }
    
    return requestURL;
}


-(NSString*)getLeader
{
    NSString* requestURL =  [NSString stringWithFormat:@"http://%@:%d/v2/leader",
                             self.serverIp,
                             self.serverPort];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:requestURL]];
    [request setHTTPMethod:@"GET"];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil error:nil];
    
    NSString* resultLog = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"%@\n", resultLog);
    
    if([resultLog hasPrefix:@"http://"])
    {
        return [resultLog substringFromIndex:7];
    }
    else
    {
        return resultLog;
    }
}



-(AMETCDResult*)getKey:(NSString*)key
{
    NSMutableString* requestURL = [self getRequestURL:key withParams:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:requestURL]];
    [request setHTTPMethod:@"GET"];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil error:nil];
    
    NSString* resultLog = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"%@\n", resultLog);
    
    AMETCDResult* result = [[AMETCDResult alloc] initWithData:returnData];
    return result;
}



-(AMETCDResult*)setKey:(NSString*)key withValue:(NSString*)value;
{
    NSString* headerfield = @"application/x-www-form-urlencoded";
    
    NSString* urlStr  = [self getRequestURL:key withParams:nil];
    
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
    
    //Log
    NSString* resultLog = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"%@\n", resultLog);


    return [[AMETCDResult alloc] initWithData:returnData];
    
}



-(AMETCDResult*)watchKey:(NSString*)key
                   fromIndex:(int)index_in
                acturalIndex:(int*)index_out
                     timeout:(int)seconds

{
    
   // http://127.0.0.1:4001/v2/keys/foo?wait=true&waitIndex=7'
    
    NSString* params = [NSString stringWithFormat:@"wait=true&waitIndex=%d", index_in];
    NSString* urlStr = [self getRequestURL:key withParams:params];
    
    NSString* headerfield = @"application/x-www-form-urlencoded";
    NSMutableDictionary* headerDictionary = [[NSMutableDictionary alloc] init];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"GET"];
    [request addValue:headerfield forHTTPHeaderField:@"Content-Type"];
    [request setAllHTTPHeaderFields:headerDictionary];
    
    if(seconds == 0)
    {
        [request setTimeoutInterval: 3600*100];
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
    
    AMETCDResult* result = [[AMETCDResult alloc] initWithData:returnData];
    
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


-(AMETCDResult*)deleteKey: (NSString*) key
{
    //curl -L http://127.0.0.1:4001/v2/keys/message -XDELETE
    NSString* urlStr  = [self getRequestURL:key withParams:nil];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"DELETE"];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil error:nil];
    
    NSString* resultLog = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"%@\n", resultLog);
    
    AMETCDResult* result = [[AMETCDResult alloc] initWithData:returnData];
    return result;
    
}


-(AMETCDResult*)createDir:(NSString*)dirPath
{
    NSString* urlStr  = [self getRequestURL:dirPath withParams:nil];
    
    NSString* headerfield = @"application/x-www-form-urlencoded";
    NSMutableData* httpBody = [self createSetKeyHttpBody:@"dir" withValue:@"true"];
    
    NSMutableDictionary* headerDictionary = [[NSMutableDictionary alloc] init];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"PUT"];
    [request addValue:headerfield forHTTPHeaderField:@"Content-Type"];
    [request setAllHTTPHeaderFields:headerDictionary];
    [request setHTTPBody: httpBody];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil error:nil];
    
    //Log
    NSString* resultLog = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"%@\n", resultLog);
    
    
    return [[AMETCDResult alloc] initWithData:returnData];

}

-(AMETCDResult*)deleteDir:(NSString*)dirPath
                recursive:(BOOL)bRecursive
{
    //curl -L http://127.0.0.1:4001/v2/keys/dir?recursive=true -XDELETE
    
    NSString* params = bRecursive ? @"recursive=true" : @"dir=true";
    NSString* urlStr = [self getRequestURL:dirPath withParams:params];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"DELETE"];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil error:nil];
    
    NSString* resultLog = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"%@\n", resultLog);
    
    AMETCDResult* result = [[AMETCDResult alloc] initWithData:returnData];
    return result;
}

-(AMETCDResult*)listDir:(NSString*)dirPath
              recursive:(BOOL)bRecursive;
{
    NSString* params = bRecursive ? @"recursive=true" : nil;
    NSString* urlStr = [self getRequestURL:dirPath withParams:params ];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"GET"];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil error:nil];
    
    NSString* resultLog = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"%@\n", resultLog);
    
    AMETCDResult* result = [[AMETCDResult alloc] initWithData:returnData];
    return result;
}


-(AMETCDResult*)watchDir:(NSString*)dirPath
               fromIndex:(int)index_in
            acturalIndex:(int*)index_out
                 timeout:(int)seconds
{
    // http://127.0.0.1:4001/v2/keys/foo?wait=true&waitIndex=7'
    
    NSString* params = [NSString stringWithFormat:@"recursive=true&wait=true&waitIndex=%d", index_in];
    NSString* urlStr  = [self getRequestURL:dirPath withParams:params];
    
     NSString* headerfield = @"application/x-www-form-urlencoded";
    NSMutableDictionary* headerDictionary = [[NSMutableDictionary alloc] init];
    
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"GET"];
    [request addValue:headerfield forHTTPHeaderField:@"Content-Type"];
    [request setAllHTTPHeaderFields:headerDictionary];
    
    if(seconds == 0)
    {
        [request setTimeoutInterval: 3600*100];
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
    
    AMETCDResult* result = [[AMETCDResult alloc] initWithData:returnData];
    
    if(result != nil && result.node != nil)
    {
        *index_out = (result.node.modifiedIndex > result.node.createdIndex )? result.node.modifiedIndex : result.node.createdIndex ;
    }
    else
    {
        *index_out = -1;
    }
    
    return result;
}


-(void)syncResult:(AMETCDResult*)res
{
    if(res.errCode != 0)
    {
        return;
    }
    
    [self syncNode:res.node];
}

-(void)syncNode:(AMETCDNode*)node
{
    
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
