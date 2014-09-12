//
//  AMJackClient.m
//  AMAudio
//
//  Created by 王 为 on 8/25/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMJackClient.h"
#include "jack.h"
#include "types.h"
#import "AMChannel.h"

#define JACK_MAX_PORTS  2048

@implementation AMJackClient
{
    jack_client_t* _client;
}

-(BOOL) openJackClient
{
    if (_client != NULL) {
        NSLog(@"openJackClient : first close old client \n");
        jack_client_close(_client);
    }
    
    _client = jack_client_open("JackArtsmesh", JackNullOption, NULL);
    if (_client == NULL) {
        self.isOpen = NO;
        return NO;
    }
    
    self.isOpen = YES;
    return YES;
}

-(NSArray*)allChannels
{
    NSMutableArray* allChannels = [[NSMutableArray alloc] init];
    if (_client == NULL) {
        return allChannels;
    }
    
    const char** ports =  jack_get_ports(_client, NULL, NULL, 0);
    if (!ports){
        return allChannels;
    }
    
    for (int i = 0; i < JACK_MAX_PORTS; i++) {
        if (ports[i] == NULL) {
            break;
        }
        
        jack_port_t* jackport = jack_port_by_name(_client, ports[i]);
        if (jackport != NULL) {
            int flag = jack_port_flags(jackport);
            
            NSString* fullChannName = [NSString stringWithFormat:@"%s", ports[i]];
            NSArray* channNamePath = [fullChannName componentsSeparatedByString:@":"];
            NSString* channName;
            NSString* deviceName;
            
            if ([channNamePath count] == 2 ) {
                deviceName = channNamePath[0];
                channName = channNamePath[1];
            }else if( [channNamePath count] == 1){
                deviceName = channNamePath[0];
                channName = channNamePath[0];
            }else{
                continue;
            }
            
            AMChannel* newChann = [[AMChannel alloc] init];
            newChann.channelName = channName;
            newChann.deviceID = deviceName;
            
            if (flag & JackPortIsInput) {
                newChann.type = AMDestinationChannel;
            }else{
                newChann.type = AMSourceChannel;
            }
            
            [allChannels addObject:newChann];
        }
    }

    jack_free(ports);
    return allChannels;
}

-(NSArray*)connectionForPort:(NSString*)portName
{
    NSMutableArray* connectNames = [[NSMutableArray alloc] init];
    
    const char* portname = [portName cStringUsingEncoding:NSUTF8StringEncoding];
    jack_port_t* jackport = jack_port_by_name(_client, portname);
    if (jackport != NULL) {
        
        const char** conns = jack_port_get_all_connections(_client, jackport);
        if(conns != NULL){
            int conn_index = 0;
            while (conns[conn_index] != 0) {
                NSString* str = [NSString stringWithFormat:@"%s", conns[conn_index]];
                [connectNames addObject:str];
                conn_index++;
            }
        }
        
        jack_free(conns);
    }
    
    return connectNames;
}

-(void)closeJackClient
{
    jack_client_close(_client);
    self.isOpen = NO;
    _client = NULL;
}

-(BOOL)connectSrc:(NSString*)src toDest:(NSString*)dest
{
    const char* srcPort = [src cStringUsingEncoding:NSUTF8StringEncoding];
    const char* desPort = [dest cStringUsingEncoding:NSUTF8StringEncoding];
    
    return 0 == jack_connect(_client, srcPort, desPort);
}

-(BOOL)disconnectChannel:(NSString*)src fromDest:(NSString*) dest
{
    const char* sourcePort = [src cStringUsingEncoding:NSUTF8StringEncoding];
    const char* desPort = [dest cStringUsingEncoding:NSUTF8StringEncoding];
    return 0 == jack_disconnect(_client, sourcePort, desPort);
}

@end
