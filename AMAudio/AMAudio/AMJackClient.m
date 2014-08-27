//
//  AMJackClient.m
//  AMAudio
//
//  Created by 王 为 on 8/25/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMJackClient.h"
#include <jack/jack.h>

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
        return NO;
    }
    
    return YES;
}

-(NSArray*)sourcePorts
{
    NSMutableArray* inputPorts = [[NSMutableArray alloc] init];
    if (_client == NULL) {
        return inputPorts;
    }
    
    const char** ports =  jack_get_ports(_client, NULL, NULL, 0);
    if (!ports){
        return inputPorts;
    }
    
    for (int i = 0; i < JACK_MAX_PORTS; i++) {
        if (ports[i] == NULL) {
            break;
        }
        
        jack_port_t* jackport = jack_port_by_name(_client, ports[i]);
        if (jackport != NULL) {
            int flag = jack_port_flags(jackport);
            if (flag & JackPortIsInput) {
        
                NSString* portname = [NSString stringWithFormat:@"%s", ports[i]];
                [inputPorts addObject:portname];
            }
        }
    }
    
    jack_free(ports);
    return inputPorts;
}

-(NSArray*)destinationPorts
{
    NSMutableArray* outputPorts = [[NSMutableArray alloc] init];
    if (_client == NULL) {
        return outputPorts;
    }
    
    const char** ports =  jack_get_ports(_client, NULL, NULL, 0);
    if (!ports){
        return outputPorts;
    }
    
    for (int i = 0; i < JACK_MAX_PORTS; i++) {
        if (ports[i] == NULL) {
            break;
        }
        
        jack_port_t* jackport = jack_port_by_name(_client, ports[i]);
        if (jackport != NULL) {
            int flag = jack_port_flags(jackport);
            if (flag & JackPortIsOutput) {
                
                NSString* portname = [NSString stringWithFormat:@"%s", ports[i]];
                [outputPorts addObject:portname];
            }
        }
    }
    
    jack_free(ports);
    return outputPorts;
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
}


-(BOOL)connectOutput:(NSString *)output toInput:(NSString *)input
{
    const char* sourcePort = [output cStringUsingEncoding:NSUTF8StringEncoding];
    const char* desPort = [input cStringUsingEncoding:NSUTF8StringEncoding];
    
    return 0 == jack_connect(_client, sourcePort, desPort);
}

-(BOOL)disconnectOutput:(NSString *)output fromInput:(NSString *)input
{
    const char* sourcePort = [output cStringUsingEncoding:NSUTF8StringEncoding];
    const char* desPort = [input cStringUsingEncoding:NSUTF8StringEncoding];
    
    return 0 == jack_disconnect(_client, sourcePort, desPort);
}

@end
