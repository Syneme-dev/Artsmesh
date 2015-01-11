//
//  AMOSCForwarder.m
//  AMOSCGroups
//
//  Created by wangwei on 29/12/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#include <cstring>
#include <iostream>
#include <vector>
#include <ctime>
#include <string>
#include <cassert>
#include <cstdlib>
#include "UdpSocket.h"
#include "OscReceivedElements.h"
#include "OscOutboundPacketStream.h"
#include "OscPacketListener.h"
#include "UdpSocket.h"
#include "IpEndpointName.h"
#include "PacketListener.h"
#include "TimerListener.h"
#import "AMOSCForwarder.h"
#import "OscTypes.h"
#import "AMLogger/AMLogger.h"
#import <AppKit/AppKit.h>
#define IP_MTU_SIZE 1536

@implementation AMOSCForwarder
{
    UdpTransmitSocket* _pSendSocket;
}

-(instancetype)init{
    if (self = [super init]) {
        _pSendSocket = NULL;
    }
    
    return self;
}

-(BOOL)openSocketWithAddr:(NSString *)remoteAddr port:(NSString*)remotePort
{
    if (_pSendSocket == NULL) {
        const char* szAddr = [remoteAddr cStringUsingEncoding:NSUTF8StringEncoding];
        int iPort = [remotePort intValue];
        _pSendSocket = new UdpTransmitSocket(IpEndpointName(szAddr, iPort));
    }
    
    return _pSendSocket != NULL;
}

-(void)closeSocket
{
    delete _pSendSocket;
    _pSendSocket = NULL;
}

-(void)dealloc{
    [self closeSocket];
}


-(void)forwardMsg:(NSString *)msg
           params:(NSArray *)params
{
    if(_pSendSocket){
        const char* szMsg = [msg cStringUsingEncoding:NSUTF8StringEncoding];
        
        char buffer[IP_MTU_SIZE];
        std::size_t bufferSize = 0;
        osc::OutboundPacketStream p( buffer, IP_MTU_SIZE );
        p << osc::BeginBundle();
        p << osc::BeginMessage( szMsg );
        
        
        for (NSDictionary *dict in params) {
            //only one key-value pair in dict
            NSString *type = [[dict allKeys] firstObject];
            id value = [dict objectForKey:type];
            
            if([type isEqualToString:@"BOOL"]){
                BOOL bVal = [value boolValue];
                p << bVal;
            }else if([type isEqualToString:@"INT"]){
                int iVal = [value intValue];
                p << iVal;
                
            }else if([type isEqualToString:@"LONG"]){
                long lVal = [value longValue];
                p << lVal;
                
            }else if([type isEqualToString:@"FLOAT"]){
                float fVal = [value floatValue];
                p << fVal;
                
            }else if([type isEqualToString:@"STRING"]){
                NSString *valStr = [NSString stringWithFormat:@"%@", value];
                const char *szParam = [valStr cStringUsingEncoding:NSUTF8StringEncoding];
                p << szParam;
            }else if([type isEqualToString:@"BLOB"]){
                
                NSData *data = (NSData *)value;
                osc::Blob blobVal([data bytes], (int)data.length);
                p << blobVal;
            }
        }
        
        p<< osc::EndMessage;
        p << osc::EndBundle;
        bufferSize = p.Size();
        
        _pSendSocket->Send(buffer, bufferSize);
    }
}


+(void)forwardMsg:(NSString *)msg
           params:(NSArray *)params
           toAddr:(NSString *)addr
             port:(NSString *)port
{
    const char* szMsg = [msg cStringUsingEncoding:NSUTF8StringEncoding];
    const char* szAddr = [addr cStringUsingEncoding:NSUTF8StringEncoding];
    int iPort = [port intValue];
    
    char buffer[IP_MTU_SIZE];
    std::size_t bufferSize = 0;
    osc::OutboundPacketStream p( buffer, IP_MTU_SIZE );
    p << osc::BeginBundle();
    p << osc::BeginMessage( szMsg );
    
    for (NSDictionary *dict in params) {
        //only one key-value pair in dict
        NSString *type = [[dict allKeys] firstObject];
        id value = [dict objectForKey:type];
        
        if([type isEqualToString:@"BOOL"]){
            BOOL bVal = [value boolValue];
            p << bVal;
        }else if([type isEqualToString:@"INT"]){
            int iVal = [value intValue];
            p << iVal;
            
        }else if([type isEqualToString:@"LONG"]){
            long lVal = [value longValue];
            p << lVal;
            
        }else if([type isEqualToString:@"FLOAT"]){
            float fVal = [value floatValue];
            p << fVal;
            
        }else if([type isEqualToString:@"STRING"]){
            NSString *valStr = [NSString stringWithFormat:@"%@", value];
            const char *szParam = [valStr cStringUsingEncoding:NSUTF8StringEncoding];
            p << szParam;
        }else if([type isEqualToString:@"BLOB"]){
            
            NSData *data = (NSData *)value;
            osc::Blob blobVal([data bytes], (int)data.length);
            p << blobVal;
        }
    }
    
    p<< osc::EndMessage;
    p << osc::EndBundle;
    bufferSize = p.Size();
    
    
    try {
        UdpTransmitSocket localRxSocket(IpEndpointName(szAddr, iPort));
        localRxSocket.Send(buffer, bufferSize);
        
    } catch(std::runtime_error err){
        NSLog(@"Can not forward osc message, please check the forward ip and port!");
        return;
    }
}



@end
