//
//  AMChatHolePunchingClient.m
//  AMMesher
//
//  Created by 王 为 on 5/14/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMChatHolePunchingClient.h"
#import "AMNetworkUtils/GCDAsyncUdpSocket.h"
#import "AMMesher/AMMesher.h"
#import "AMMesher/AMUser.h"
#import "AMPreferenceManager/AMPreferenceManager.h"

@implementation AMChatHolePunchingClient
{
    GCDAsyncUdpSocket* _chatSocket;
    NSString* _holePunchingServerIp;
    NSString* _holePunchingServerPort;
    
    NSTimer* _toHolePunchingServerTTL;
    NSTimer* _toPeerTTL;
}

-(id)initWithPort:(NSString*)port server:(NSString*)ip serverPort:(NSString*)serverPort
{
    if (self = [super init])
    {
        _chatSocket = [[GCDAsyncUdpSocket alloc]
                          initWithDelegate:self
                          delegateQueue:dispatch_get_main_queue()];
        
		NSError *error = nil;
		if (![_chatSocket bindToPort:[port intValue] error:&error])
		{
			return nil;
		}
		if (![_chatSocket beginReceiving:&error])
		{
            [_chatSocket close];
            return nil;
        }
        
        _holePunchingServerIp = ip;
        _holePunchingServerPort = serverPort;
    }
    
    return self;
}


-(void)sendPacket:(NSData*)data toHost:(NSString*)host toPort:(NSString*)toPort
{
    [_chatSocket sendData:data toHost:host port:[toPort intValue] withTimeout:-1 tag:0];
}


-(void)startHolePunching
{
    [self sendTTLToServer];
    [self sendTTLToPeers];
    _toHolePunchingServerTTL = [NSTimer scheduledTimerWithTimeInterval:10
                                                                target:self
                                                              selector:@selector(sendTTLToServer)
                                                              userInfo:nil
                                                               repeats:YES];
    
    _toPeerTTL = [NSTimer scheduledTimerWithTimeInterval:10
                                                  target:self
                                                selector:@selector(sendTTLToPeers)
                                                userInfo:nil
                                                 repeats:YES];
}

-(void)stopHolePunching
{
    [_toHolePunchingServerTTL invalidate];
    [_toPeerTTL invalidate];
    [_chatSocket close];
}

-(void)sendTTLToServer
{
    NSString* msg = [NSString stringWithFormat:@"get public ip and port"];
    NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
    
    [_chatSocket sendData:data toHost:_holePunchingServerIp
                     port:[_holePunchingServerPort intValue]
              withTimeout:-1 tag:0];
}

-(void)sendTTLToPeers
{
    AMMesher* mesher = [AMMesher sharedAMMesher];
    NSString* myName = mesher.mySelf.uniqueName;
    
    for(AMUser* user in mesher.myGroupUsers)
    {
        if ([user.uniqueName isEqualToString:myName])
        {
            continue;
        }
        
        if (user.chatPortMap == nil || [user.chatPortMap isEqualToString:@""])
        {
            continue;
        }
        
        if ([user.location isEqualToString: mesher.mySelf.location]
            && [user.domain isEqualToString:mesher.mySelf.domain])
        {
            continue;
        }
        
        NSString* msg = [NSString stringWithFormat:@"HB"];
        NSData *data = [msg dataUsingEncoding:NSUTF8StringEncoding];
        
        [_chatSocket sendData:data toHost:user.publicIp
                         port:[user.chatPortMap intValue]
                  withTimeout:-1 tag:0];
        
    }
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
    NSString* fromHost = [GCDAsyncUdpSocket hostFromAddress:address];
    if (![fromHost isEqualToString:_holePunchingServerIp])
    {
        NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSLog(@"%@ send message:%@", fromHost, msg);
        
        [self.msgDelegate handleIncomingData:data fromAddress:address];
    }
    
	NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (msg == nil || [msg isEqualToString:@""])
    {
        return;
    }
    
    NSArray* ipAndPort = [msg componentsSeparatedByString:@":"];
    if ([ipAndPort count] < 2)
    {
        return;
    }
    
    NSString* myPubIp = [ipAndPort objectAtIndex:0];
    NSString* myPubPort = [ipAndPort objectAtIndex:1];
    if (![self.myPublicIp isEqualToString:myPubIp])
    {
        AMMesher* mesher = [AMMesher sharedAMMesher];
        NSDictionary* props =  [NSDictionary dictionaryWithObjectsAndKeys:
                                 myPubIp, @"publicIp",
                                 nil];
        [mesher updateMySelfProperties:props];
        
        self.myPublicIp = myPubIp;
        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:myPubIp forKey:Preference_Key_General_PublicIP];
    }
    
    if (![self.myChatPortMap isEqualToString:myPubPort])
    {
        AMMesher* mesher = [AMMesher sharedAMMesher];
        NSDictionary* props =  [NSDictionary dictionaryWithObjectsAndKeys:
                                myPubPort, @"chatPortMap",
                                nil];
        [mesher updateMySelfProperties:props];
    }
}

@end
