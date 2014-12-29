//
//  AMOSCForwarder.m
//  AMOSCGroups
//
//  Created by wangwei on 29/12/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import "AMOSCForwarder.h"
#import "AMNetworkUtils/GCDAsyncUdpSocket.h"
#import "AMLogger/AMLogger.h"

@implementation AMOSCForwarder
{
    GCDAsyncUdpSocket *udpSocket;
    long tag;
}


-(instancetype)init
{
    if(self = [super init]){
        tag = 0;
        
        udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        NSError *error = nil;
        
        if (![udpSocket bindToPort:0 error:&error])
        {
            AMLog(kAMErrorLog, @"OSCModule", @"Error when initialize osc forwarder: %@", error);
            return nil;
        }
        if (![udpSocket beginReceiving:&error])
        {
            AMLog(kAMErrorLog, @"OSCModule", @"Error when initialize osc forwarder: %@", error);
            return nil;
        }
        
        AMLog(kAMInfoLog, @"OSCModule", @"OSC Forwarder Ready!");
    }
    
    return self;
}

-(void)forwardMessage:(NSData *)oscPack
{
    if (self.forwardAddr  != nil && self.forwardAddr != nil) {
        [self forwardMessage:oscPack toAddr:self.forwardAddr port:self.forwardPort];
    }
}


-(void)forwardMessage:(NSData *)oscPack toAddr:(NSString *)addr port:(NSString *)port
{
    [udpSocket sendData:oscPack toHost:addr port:[port intValue] withTimeout:-1 tag:tag];
    tag ++;
    
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)t
{
    AMLog(kAMInfoLog, @"OSCModule", @"Forward OSC pack succeeded, tag %ld!", t);
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)t dueToError:(NSError *)error
{
    AMLog(kAMInfoLog, @"OSCModule", @"Forward OSC pack failed, tag %ld, error %@", t, error);
}



@end
