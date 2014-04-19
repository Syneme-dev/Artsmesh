//
//  AMCommunicator.m
//  AMMesher
//
//  Created by Wei Wang on 4/16/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMCommunicator.h"
#import "AMNetworkUtils/GCDAsyncUdpSocket.h"
#import "AMMesher.h"

@implementation AMCommunicator
{
    GCDAsyncUdpSocket* _controlSocket;
}

-(id)initWithPort:(NSString*)controlPort;
{
    if (self = [super init])
    {
        _controlSocket = [[GCDAsyncUdpSocket alloc]
                            initWithDelegate:self
                            delegateQueue:dispatch_get_main_queue()];
        
		NSError *error = nil;
		if (![_controlSocket bindToPort:[controlPort intValue] error:&error])
		{
			return nil;
		}
		if (![_controlSocket beginReceiving:&error])
		{
			[_controlSocket close];
			return nil;
		}
    }
    
    return self;
}

-(void)goOnlineCommand:(NSString*)ip port:(NSString*)port
{
    NSString* msg = @"/AMMesher/Command/goOnline";
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    
    [_controlSocket sendData:data toHost:ip port:[port intValue] withTimeout:-1 tag:0];
}

-(void)joinGroupCommand:(NSString*)groupName ip:(NSString*)ip port:(NSString*)port
{
    NSString* msg = [NSString stringWithFormat:@"/AMMesher/Command/joinGroup:%@", groupName];
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    
    [_controlSocket sendData:data toHost:ip port:[port intValue] withTimeout:-1 tag:0];
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
	// You could add checks here
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error
{
	// You could add checks here
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock
   didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
	NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	if (msg)
	{
		NSArray* commandPathes = [msg componentsSeparatedByString:@"/"];
        if ([commandPathes count] < 3)
        {
            return;
        }
        
        if (![[commandPathes objectAtIndex:1] isEqualToString:@"AMMesher"])
        {
            return;
        }
        
        if ([[commandPathes objectAtIndex:2] isEqualToString:@"Command"])
        {
            if ([commandPathes count] < 4)
            {
                return;
            }
            
            NSString* commandType = [commandPathes objectAtIndex:3];
            if ([commandType hasPrefix:@"goOnline"])
            {
                [[AMMesher sharedAMMesher] goOnline];
            }
            else if ([commandType hasPrefix:@"joinGroup"])
            {
                NSArray* joinParams = [commandType componentsSeparatedByString:@":"];
                if([joinParams count] < 2)
                {
                    return;
                }
                
                NSString* groupName = [joinParams objectAtIndex:1];
                [[AMMesher sharedAMMesher] joinGroup:groupName];
            }
        }
        else if ([[commandPathes objectAtIndex:1] isEqualToString:@"Chat"])
        {
            NSLog(@"chat message comming");
        }
	}
	else
	{
		NSLog(@"Error converting received data into UTF-8 String");
	}
    
    //confirm received
	//[_udpSendSocket sendData:data toAddress:address withTimeout:-1 tag:0];
}


@end
