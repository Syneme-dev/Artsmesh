//
//  AMNetworkUtils.m
//  AMNetworkUtils
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMNetworkUtils.h"


@implementation AMNetworkUtils


//
//

//
//+(NSString*)getHostIpv4Addr
//{
//    NSHost* host = [NSHost currentHost];
//    for(NSString* addr in host.addresses)
//    {
//        if([AMNetworkUtils isValidIpv4:addr])
//        {
//            if(![addr isEqualToString:@"127.0.0.1"])
//            {
//                return addr;
//            }
//        }
//    }
//    
//    return nil;
//}
//
//
//+(NSString*)getHostIpv6Addr
//{
//    NSHost* host = [NSHost currentHost];
//    for(NSString* addr in host.addresses)
//    {
//        if([AMNetworkUtils isValidIpv6:addr])
//        {
//            if(![addr isEqualToString:@"::1"])
//            {
//                return addr;
//            }
//        }
//    }
//    
//    return nil;
//}
//
//
//+(NSString*)getHostName
//{
//    NSHost* host = [NSHost currentHost];
////    NSArray* hostName = [host.name componentsSeparatedByString:@"."];
////    
////    return hostName[0];
//    
//    return host.name;
//}
//
//

//
//
//+(NSData*)addressFromIpAndPort:(NSString*)ipStr
//                          port:(int)p
//{
//    struct sockaddr_in ip;
//    ip.sin_family = AF_INET;
//    ip.sin_port = htons(p);
//    inet_pton(AF_INET, [ipStr cStringUsingEncoding:NSUTF8StringEncoding], &ip.sin_addr);
//    
//    return [NSData dataWithBytes:&ip length:sizeof(ip)];
//}


@end
