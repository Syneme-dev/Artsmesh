//
//  AMUserGroupClient.m
//  UserGroupModule
//
//  Created by Wei Wang on 3/21/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMUserGroupClient.h"
#import "AMNetworkUtils/GCDAsyncUdpSocket.h"

@implementation AMUserGroupClient
{
    GCDAsyncUdpSocket *udpSocket;
}


-(id)init
{
    if(self = [super init])
    {
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

-(void)RegsterUser:(NSData*)serverAddr name:(NSString*)userName withPort:(int)port
{
    NSString* reqStr = [NSString stringWithFormat:@"/Ctrl/RegsterUser?username=%@&port=%d", userName, port];
    [self sendRequest:[reqStr dataUsingEncoding:NSUTF8StringEncoding] toAddr:serverAddr ];
}

-(void)UnregisterUser:(NSData*)serverAddr name:(NSString*)userName
{
    NSString* reqStr = [NSString stringWithFormat:@"/Ctrl/UnregsterUser?username=%@", userName];
    [self sendRequest:[reqStr dataUsingEncoding:NSUTF8StringEncoding] toAddr:serverAddr ];
}


-(void)sendRequest:(NSData*)data
            toAddr:(NSData*)addr
{
    [udpSocket sendData:data toAddress:addr withTimeout:-1 tag:0];
}

-(void)sendUserInfo:(NSData*)serverAddr userInfo:(NSString*)userInfo
{
    NSString* reqStr = [NSString stringWithFormat:@"/Ctrl/UnregsterUser?username=%@", userInfo];
    [self sendRequest:[reqStr dataUsingEncoding:NSUTF8StringEncoding] toAddr:serverAddr ];
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
    
    NSError *jsonParsingError = nil;
    id objects = [NSJSONSerialization JSONObjectWithData:data
                                                 options:0
                                                   error:&jsonParsingError];
    if(jsonParsingError != nil)
    {
        return;
    }
    
    if(![objects isKindOfClass:[NSDictionary class]])
    {
        return;
    }
    
    NSDictionary* resDic = objects;
    
    for (NSString* key in resDic)
    {
        NSArray* requestPaths = [key componentsSeparatedByString:@"/"];
       
        if(requestPaths == nil)
        {
            return;
        }
        
        if ([requestPaths count] < 4)
        {
            return;
        }
        
        if(![[requestPaths objectAtIndex:3] isEqualToString:@"Results"])
        {
            return;
        }
        
        if([requestPaths[2] isEqualToString:@"GetGroups"])
        {
            if (self.delegate)
            {
                [self.delegate didGetGroups:[resDic objectForKey:key]];
            }
        }
        
        if([requestPaths[2] isEqualToString:@"GetUsers"])
        {
            if (self.delegate)
            {
                [self.delegate didGetUsers:[resDic objectForKey:key]];
            }
        }
        
        if([requestPaths[2] isEqualToString:@"RegsterUser"])
        {
            if (self.delegate)
            {
                [self.delegate didRegsterUser:[resDic objectForKey:key]];
            }
        }
    }
}


@end
