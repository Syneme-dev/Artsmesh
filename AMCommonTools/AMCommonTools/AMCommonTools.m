//
//  AMCommonTools.m
//  AMCommonTools
//
//  Created by Wei Wang on 7/17/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMCommonTools.h"
#include <sys/socket.h>
#include <netinet/in.h>

@implementation AMCommonTools

+ (NSString*) creatUUID
{
    // Create universally unique identifier (object)
    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    
    // Get the string representation of CFUUID object.
    NSString *uuidStr = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidObject));
    CFRelease(uuidObject);
    
    return uuidStr;
}

+ (BOOL)isValidIpv4:(NSString *)ip {
    const char *utf8 = [ip UTF8String];
    
    // Check valid IPv4.
    struct in_addr dst;
    int success = inet_pton(AF_INET, utf8, &(dst.s_addr));
    return (success == 1);
}

+ (BOOL) isValidGlobalIpv6:(NSString*)ipv6
{
    if(![self isValidIpv6:ipv6])
        return NO;
    
    if([ipv6 hasPrefix:@"::1"]    || [ipv6 hasPrefix:@"[::1"]  ||
       [ipv6 hasPrefix:@"fe80::"] || [ipv6 hasPrefix:@"[fe80::"]){
        return NO;
    }
    
    return YES;
}

+ (BOOL)isValidIpv6:(NSString *)ip {
    const char *utf8 = [ip UTF8String];

    // Check valid IPv6.
    struct in6_addr dst6;
    int success = inet_pton(AF_INET6, utf8, &dst6);

    return (success == 1);
}

+(NSString*)getCurrentTimeString
{
    NSDate * now = [NSDate date];
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"HH:mm:ss"];
    NSString *newDateString = [outputFormatter stringFromDate:now];
    
    return newDateString;
}

@end
