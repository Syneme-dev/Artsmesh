//
//  AMNetworkUtils.h
//  AMNetworkUtils
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMNetworkUtils : NSObject

+ (BOOL)isValidIpv4:(NSString *)ip;

+ (BOOL)isValidIpv6:(NSString *)ip;

//return the first ipv4 address
+(NSString*)getHostIpv4Addr;

//return the first ipv6 address
+(NSString*)getHostIpv6Addr;

+(NSString*)getHostName;

+(NSString*)getCurrentTimeString;

+(NSData*)addressFromIpAndPort:(NSString*)ipStr
                          port:(int)p;

@end
