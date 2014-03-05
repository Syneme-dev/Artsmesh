//
//  AMETCDApi.m
//  HttpAndJson
//
//  Created by 王 为 on 2/27/14.
//  Copyright (c) 2014 王 为. All rights reserved.
//

#import "AMETCDApi.h"

@implementation AMETCDApi

-(AMETCDCURDResult*)getKey:(NSString*)key
{
    if(self.serverAddr == nil)
    {
        [NSException raise:@"invalid Oper" format:@"server is not set!"];
    }
    
    NSString* urlStr  = [NSString stringWithFormat:@"http://%@/v2/keys/%@", self.serverAddr, key];
    
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
    if(self.serverAddr == nil)
    {
        [NSException raise:@"invalid Oper" format:@"server is not set!"];
    }
    
    NSString* headerfield = @"application/x-www-form-urlencoded";
    NSString* urlStr  = [NSString stringWithFormat:@"http://%@/v2/keys/%@", self.serverAddr, key];
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
    
    if(self.serverAddr == nil)
    {
        [NSException raise:@"invalid Oper" format:@"server is not set!"];
    }

    NSString* headerfield = @"application/x-www-form-urlencoded";
    NSString* urlStr  = [NSString stringWithFormat:@"http://%@/v2/keys/%@?wait=true&waitIndex=%d", self.serverAddr, key, index_in];
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
    
    if(self.serverAddr == nil)
    {
        [NSException raise:@"invalid Oper" format:@"server is not set!"];
    }
    
    NSString* urlStr  = [NSString stringWithFormat:@"http://%@/v2/keys/%@", self.serverAddr, key];
    
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
