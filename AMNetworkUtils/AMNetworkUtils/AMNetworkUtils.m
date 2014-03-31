//
//  AMNetworkUtils.m
//  AMNetworkUtils
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMNetworkUtils.h"
#include <sys/socket.h>
#include <netinet/in.h>

@implementation AMNetworkUtils

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

+(NSString*)getHostIpv4Addr
{
    NSHost* host = [NSHost currentHost];
    for(NSString* addr in host.addresses)
    {
        if([AMNetworkUtils isValidIpv4:addr])
        {
            if(![addr isEqualToString:@"127.0.0.1"])
            {
                return addr;
            }
        }
    }
    
    return nil;
}


+(NSString*)getHostIpv6Addr
{
    NSHost* host = [NSHost currentHost];
    for(NSString* addr in host.addresses)
    {
        if([AMNetworkUtils isValidIpv6:addr])
        {
            if(![addr isEqualToString:@"::1"])
            {
                return addr;
            }
        }
    }
    
    return nil;
}


+(NSString*)getHostName
{
    NSHost* host = [NSHost currentHost];
    NSArray* hostName = [host.name componentsSeparatedByString:@"."];
    
    return hostName[0];
}


+(NSString*)getCurrentTimeString
{
    NSDate * now = [NSDate date];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"HH:mm:ss"];
    NSString *newDateString = [outputFormatter stringFromDate:now];

    return newDateString;
}


+(NSData*)addressFromIpAndPort:(NSString*)ipStr
                          port:(int)p
{
    struct sockaddr_in ip;
    ip.sin_family = AF_INET;
    ip.sin_port = htons(p);
    inet_pton(AF_INET, [ipStr cStringUsingEncoding:NSUTF8StringEncoding], &ip.sin_addr);
    
    return [NSData dataWithBytes:&ip length:sizeof(ip)];
}


@end
