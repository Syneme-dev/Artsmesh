//
//  AMUserGroupDataDeletage.m
//  UserGroupModule
//
//  Created by Wei Wang on 3/21/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMUserGroupDataDeletage.h"
#import "AMUserGroupServer.h"
#import "AMNetworkUtils/GCDAsyncUdpSocket.h"

@implementation AMUserGroupDataDeletage
{
    AMUserGroupServer* server;
}

-(id)initWithDataSource:(AMUserGroupServer*)s
{
    if(self = [super init])
    {
        server = s;
    }
    
    return self;
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock
   didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
	NSString *request = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", request);
	
	//[udpSocket sendData:data toAddress:address withTimeout:-1 tag:0];
}



@end
