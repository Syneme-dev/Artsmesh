//
//  AMSystemConfig.m
//  AMCoreData
//
//  Created by Wei Wang on 7/17/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMSystemConfig.h"
#import "AMCommonTools/AMCommonTools.h"

@implementation AMSystemConfig

-(NSArray *)localServerIpv4s
{
    NSMutableArray *validIpv4 = [[NSMutableArray alloc] init];
    
    for (NSString *ip in self.localServerIps) {
        if ([AMCommonTools isValidIpv4:ip]) {
            if(![ip hasPrefix:@"127"]){
                [validIpv4 addObject:ip];
            }
        }
    }
    
    return validIpv4;
}


-(NSArray *)localServerIpv6s
{
    NSMutableArray *validIpv6 = [[NSMutableArray alloc] init];
    
    for (NSString *ip in self.localServerIps) {
        if ([AMCommonTools isValidIpv6:ip]) {
            if(![ip hasPrefix:@"::1"]){
                [validIpv6 addObject:ip];
            }
        }
    }
    
    return validIpv6;
}


@end
