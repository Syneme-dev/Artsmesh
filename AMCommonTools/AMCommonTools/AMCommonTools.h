//
//  AMCommonTools.h
//  AMCommonTools
//
//  Created by Wei Wang on 7/17/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMCommonTools : NSObject

+ (NSString*) creatUUID;

+ (BOOL)isValidIpv4:(NSString *)ip;

+ (BOOL)isValidIpv6:(NSString *)ip;

+(NSString*)getCurrentTimeString;

@end
