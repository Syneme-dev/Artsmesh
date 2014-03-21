//
//  AMUserGroupServer.m
//  UserGroupModule
//
//  Created by 王 为 on 3/20/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMUserGroupServer.h"
#import "AMNetworkUtils/GCDAsyncUdpSocket.h"

@implementation AMUserGroupServer
{
    GCDAsyncUdpSocket *listenSocket;
    BOOL isRunning;
}

-(id)init
{
    if(self = [super init])
    {
        isRunning = NO;
        self.listenPort = 7001;
        listenSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    
    return self;
}


-(BOOL)startServer
{
    if(isRunning)
    {
        return YES;
    }
    
    NSError *error = nil;
    
    if (![listenSocket bindToPort:self.listenPort error:&error])
    {
        NSLog(@"Error starting server (bind): %@", error);
        return NO;
    }
    if (![listenSocket beginReceiving:&error])
    {
        [listenSocket close];
        
        NSLog(@"Error starting server (recv): %@", error);
        return NO;
    }
    
    NSLog(@"Udp Echo server started on port %hu", [listenSocket localPort]);
    isRunning = YES;
    
    return YES;
}

-(void)stopServer
{
    [listenSocket close];
    
    NSLog(@"Stopped server");
    isRunning = NO;
    listenSocket = nil;
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock
   didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
	NSString *urlStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", urlStr);
	
	NSURL* url = [NSURL URLWithString:urlStr];
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
    
    if([pathArray[2] isEqualToString:@"RegsterUser"])
    {
        if(self.delegate)
        {
            NSMutableDictionary* user = [[NSMutableDictionary alloc] init];
            
            for (NSString* keyVal in keyvalues)
            {
                NSArray* tempArr = [keyVal componentsSeparatedByString:@"="];
                if([tempArr count] < 2)
                {
                    return;
                }
               
                [user setObject:tempArr[1] forKey:tempArr[0]];
            }
            
            NSString* name = [user objectForKey:@"username"];
            int port = [[user objectForKey:@"port"] intValue];
            
            if (name == nil || port <=0 )
            {
                return;
            }

            [self.delegate RegisterUserHandler:sock
                                   fromAddress:address
                                   withRequest:requestPath
                                      username:name
                                       usePort:port];
        }
        
        return;
    }
    
    if([pathArray[2] isEqualToString:@"Unregister"])
    {
        if(self.delegate)
        {
            NSMutableDictionary* user = [[NSMutableDictionary alloc] init];
            
            for (NSString* keyVal in keyvalues)
            {
                NSArray* tempArr = [keyVal componentsSeparatedByString:@"="];
                if([tempArr count] < 1)
                {
                    return;
                }
                
                [user setObject:tempArr[1] forKey:tempArr[0]];
            }
            
            NSString* name = [user objectForKey:@"username"];
            
            if (name == nil)
            {
                return;
            }
            
            [self.delegate UnregisterUserHandler:sock
                                   fromAddress:address
                                   withRequest:requestPath
                                      username:name];
        }
    }
    
    if([pathArray[2] isEqualToString:@"GetGroups"])
    {
        if(self.delegate)
        {
            [self.delegate GetGroupsHandler:sock
                                fromAddress:address
                                withRequest:requestPath];
        }
        
        return;
    }
    
    if([pathArray[2] isEqualToString:@"GetUsers"])
    {
        if(self.delegate)
        {
            [self.delegate GetUsersHandler:sock
                                fromAddress:address
                                withRequest:requestPath];
        }
        
        return;
    }
}



@end
