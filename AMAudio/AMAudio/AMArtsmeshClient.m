//
//  AMArtsmeshClient.m
//  AMAudio
//
//  Created by 王为 on 10/11/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMArtsmeshClient.h"

#import "AMJackHelper.h"
#import <jack/jack.h>


void JackShutDownCallBack(void* arg)
{
    NSLog(@"client has been shutdown by Jack!");
    
    AMArtsmeshClient* cl = (__bridge AMArtsmeshClient*)arg;
    if (cl != nil) {
        if ([cl.delegate respondsToSelector:@selector(jackShutDownClient:)]) {
            [cl.delegate jackShutDownClient:cl];
        }
    }
}

void Client_RegistrationCallBack(const char *name, int reg, void *arg)
{
    if (reg == 0) {
        
        NSLog(@"Client %s is unregistered!", name);
        
        AMArtsmeshClient* cl = (__bridge AMArtsmeshClient*)arg;
        if (cl != nil) {
            if ([cl.delegate respondsToSelector:@selector(clientUnregistered:)]) {
                NSString* str = [NSString stringWithFormat:@"%s", name];
                [cl.delegate clientUnregistered:str];
            }
        }
        
    }else{
        NSLog(@"Client %s is registered!", name);
        
        AMArtsmeshClient* cl = (__bridge AMArtsmeshClient*)arg;
        if (cl != nil) {
            if ([cl.delegate respondsToSelector:@selector(clientRegistered:)]) {
                NSString* str = [NSString stringWithFormat:@"%s", name];
                [cl.delegate clientRegistered:str];
            }
        }
    }
}

void Port_RegistrationCallback(jack_port_id_t port, int reg, void *arg)
{
    if (reg == 0) {
        NSLog(@"Port %u is unregistered!", port);
        AMArtsmeshClient* cl = (__bridge AMArtsmeshClient*)arg;
        if (cl != nil) {
            if ([cl.delegate respondsToSelector:@selector(portUnregistered:)]) {
                [cl.delegate portUnregistered:port];
            }
        }
        
    }else{
        NSLog(@"Port %u is registered!", port);
        AMArtsmeshClient* cl = (__bridge AMArtsmeshClient*)arg;
        if (cl != nil) {
            if ([cl.delegate respondsToSelector:@selector(portRegistered:)]) {
                [cl.delegate portRegistered:port];
            }
        }
    }
}


void Port_ConnectCallback(jack_port_id_t a, jack_port_id_t b, int connect, void* arg)
{
    if (connect == 0) {
        NSLog(@"Port %u and %u is disconnected!", a, b);
    }else{
        NSLog(@"Port %u and %u is connected!", a, b);
    }
}


int Graph_OrderCallback(void *arg)
{
    NSLog(@"Jack connection graph changed!");
    return 0;
}


int Data_ProcessCallback (jack_nframes_t nframes, void *arg)
{
    AMArtsmeshClient* cl = (__bridge AMArtsmeshClient*)arg;
    if (cl != nil) {
        for (PortPair *pp in cl.portPairs) {
            
            float peak = 0.0;
            float vol = 0.0;
            jack_default_audio_sample_t *inbuf = jack_port_get_buffer (pp.inputPort.port_handle, nframes);
            jack_default_audio_sample_t *outbuf = jack_port_get_buffer (pp.outputPort.port_handle, nframes);
            
            if (!pp.inputPort.isMute) {
                vol = pp.inputPort.volume;
            }

            //meter * volume
            for (int i = 0; i < nframes; i++) {
                outbuf[i] = inbuf[i] * vol;
                peak = peak > inbuf[i] ? peak: inbuf[i];
            }
            
            if ([cl.delegate respondsToSelector:@selector(port:currentPeak:)]) {
                [cl.delegate port:pp.inputPort currentPeak:peak];
            }
        }
    }
    
    return 0;
}


@implementation PortPair
@end


@interface AMArtsmeshClient ()
@property NSMutableArray* portPairs;
@end


@implementation AMArtsmeshClient
{
    jack_client_t* _jackcl;
}


-(id)initWithChannelCounts:(int)nCounts
{
    if (self = [super init]) {
        self.portPairs = [[NSMutableArray alloc] init];
        for (int i = 0; i < nCounts; i++) {
            
            PortPair* portPair = [[PortPair alloc] init];
            
            portPair.inputPort = [[AMJackPort alloc] init];
            portPair.inputPort.name = [NSString stringWithFormat:@"input%d", i+1];
            portPair.inputPort.portType = AMJackPort_Source;
            
            portPair.outputPort = [[AMJackPort alloc] init];
            portPair.outputPort.name = [NSString stringWithFormat:@"output%d", i+1];
            portPair.outputPort.portType = AMJackPort_Destination;
            
            [self.portPairs addObject:portPair];
        }
    }
    
    return self;
}


-(BOOL)registerClient
{
    jack_status_t status;
    _jackcl = jack_client_open("ArtsmeshClient", JackNoStartServer, &status);
    
    if (_jackcl == NULL) {
        NSString* strErr = [AMJackHelper jackStatusToString:status];
        NSLog(@"jack_client_open failed. error code is: %@", strErr);
        return NO;
    }
    
    jack_on_shutdown(_jackcl, JackShutDownCallBack, (__bridge_retained void*)self);
    
    int nRet = jack_set_client_registration_callback(_jackcl, Client_RegistrationCallBack, (__bridge void*)self);
    if (nRet != 0) {
        NSLog(@"jack_set_client_registration_callback failed!");
        return NO;
    }
    
    nRet = jack_set_port_registration_callback(_jackcl, Port_RegistrationCallback, (__bridge void*)self);
    if (nRet != 0) {
        NSLog(@"jack_set_port_registration_callback failed!");
        return NO;
    }
    
    nRet = jack_set_port_connect_callback(_jackcl, Port_ConnectCallback, (__bridge void*)self);
    if (nRet != 0) {
        NSLog(@"jack_set_port_connect_callback failed!");
        return NO;
    }
    
    nRet = jack_set_graph_order_callback(_jackcl, Graph_OrderCallback,  (__bridge void*)self);
    if (nRet != 0) {
        NSLog(@"jack_set_graph_order_callback failed!");
        return NO;
    }
    
    jack_nframes_t bufSize = jack_get_buffer_size(_jackcl);
    for (PortPair* pp in self.portPairs) {
        pp.inputPort.port_handle =
        jack_port_register(_jackcl,
                           [pp.inputPort.name cStringUsingEncoding:NSUTF8StringEncoding],
                           JACK_DEFAULT_AUDIO_TYPE,
                           JackPortIsInput | JackPortCanMonitor,
                           bufSize);
        pp.outputPort.port_handle =
        jack_port_register(_jackcl,
                           [pp.outputPort.name cStringUsingEncoding:NSUTF8StringEncoding],
                           JACK_DEFAULT_AUDIO_TYPE,
                           JackPortIsOutput | JackPortCanMonitor,
                           bufSize);
    }
    
    nRet = jack_set_process_callback(_jackcl, Data_ProcessCallback, (__bridge void*)self);
    if (nRet != 0) {
        NSLog(@"jack_set_process_callback failed!");
        return NO;
    }
    
    jack_activate(_jackcl);
    
    return YES;
}


-(void)unregisterClient
{
    for (PortPair* pp in self.portPairs) {
        jack_port_unregister(_jackcl, pp.inputPort.port_handle);
        jack_port_unregister(_jackcl, pp.outputPort.port_handle);
    }
    
    jack_deactivate(_jackcl);
    jack_client_close(_jackcl);
    _jackcl = NULL;
    
}


-(NSArray*)allPorts
{
    NSMutableArray* channs = [[NSMutableArray alloc] init];
    for (PortPair *pp in self.portPairs) {
        [channs addObject:pp.inputPort];
        [channs addObject:pp.outputPort];
    }
    
    return channs;
}

-(float)cpuLoad
{
    if (_jackcl) {
        return jack_cpu_load(_jackcl);
    }
    
    return 0.0f;
}


-(int)bufferSize
{
    if (_jackcl) {
        return jack_get_buffer_size(_jackcl);
    }
    
    return 0;
}


-(int)sampleRate
{
    if (_jackcl) {
        return jack_get_sample_rate(_jackcl);
    }
    
    return 0;
}


@end
