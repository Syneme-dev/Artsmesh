//
//  AMUserGroupClient.m
//  UserGroupModule
//
//  Created by Wei Wang on 3/21/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMUserGroupClient.h"
#import "AMNetworkUtils/GCDAsyncUdpSocket.h"
#import "AMUserGroupModel.h"

@implementation AMUserGroupClient
{
    GCDAsyncUdpSocket *udpSocket;
    AMUserGroupModel* model;
}


-(id)initWithDataModel:(AMUserGroupModel*)m
{
    if(self = [super init])
    {
        model = m;
        
        udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        NSError *error = nil;
        if (![udpSocket bindToPort:0 error:&error])
        {
            return nil;
        }
        if (![udpSocket beginReceiving:&error])
        {
            return nil;
        }
    }
    
    return self;
}


-(void)getGroups:(NSData*)serverAddr
{
    // /Ctrl/GetGroups
    NSData* requestData = [@"/Ctrl/GetGroups" dataUsingEncoding:NSUTF8StringEncoding];
    [self sendRequest:requestData toAddr:serverAddr ];
}

-(void)getUsers:(NSData*)serverAddr
{
    // /Ctrl/GetUsers
    NSData* requestData = [@"/Ctrl/GetUsers" dataUsingEncoding:NSUTF8StringEncoding];
    [self sendRequest:requestData toAddr:serverAddr ];
}


-(void)sendRequest:(NSData*)data
            toAddr:(NSData*)addr
{
    [udpSocket sendData:data toAddress:addr withTimeout:-1 tag:0];
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
	// You could add checks here
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
	// You could add checks here
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
	NSString *response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    NSLog(@"%@", response);
	
	NSURL* url = [NSURL URLWithString:response];
    if(url == nil)
    {
        return;
    }
    
    NSString* requestPath = url.path;
    NSString* query = url.query;
    
    NSArray* pathArray = [requestPath componentsSeparatedByString:@"/"];
    NSArray* keyvalues = [query componentsSeparatedByString:@"&"];
    
    if([pathArray count] < 3)
    {
        return;
    }
    
    if(![pathArray[1] isEqualToString:@"Ctrl"])
    {
        return;
    }
    
    if([pathArray[2] isEqualToString:@"Register"])
    {
        
        return;
    }
    
    if([pathArray[2] isEqualToString:@"GetGroups"])
    {
        if (self.delegate)
        {
            [self.delegate didGetGroups:response];
        }
        return;
    }
	
}


@end
