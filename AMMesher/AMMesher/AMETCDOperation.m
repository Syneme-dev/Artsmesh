//
//  AMETCDOperation.m
//  AMMesher
//
//  Created by Wei Wang on 4/7/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDOperation.h"
#import "AMETCDApi/AMETCD.h"

@implementation AMETCDOperation

-(id)init:(NSString*)ip
     port:(NSString*)port
{
    if (self = [super init])
    {
        self.etcdApi = [[AMETCD alloc]init];
        self.etcdApi.serverIp = ip;
        self.etcdApi.clientPort = [port intValue];
    
        self.isResultOK = NO;
    }
    
    return self;
}


-(void)main
{
    return;
}

@end
