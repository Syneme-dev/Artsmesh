//
//  AMOSCMonitor.mm
//  AMOSCGroups
//
//  Created by wangwei on 10/12/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#include <iostream>
#include <cstring>

#if defined(__BORLANDC__) // workaround for BCB4 release build intrinsics bug
namespace std {
    using ::__strcmp__;  // avoid error: E2316 '__strcmp__' is not a member of 'std'.
}
#endif

#include "OscReceivedElements.h"
#include "OscPacketListener.h"
#include "UdpSocket.h"

#import "AMOSCMonitor.h"
AMOSCMonitor *g_OSCMonitor = nil;

class OSCPacketParser : public osc::OscPacketListener {

protected:
    
    virtual void ProcessPacket( const char *data, int size,
                               const IpEndpointName& remoteEndpoint )
    {
        if (g_OSCMonitor != nil) {
            
            if([g_OSCMonitor.delegate respondsToSelector:@selector(receivedOscMsg:)]){
                NSData *oscData = [NSData dataWithBytes:data length:size];
                [g_OSCMonitor.delegate receivedOscMsg:oscData];
            }
        }
        
        osc::OscPacketListener::ProcessPacket(data, size, remoteEndpoint);
    }
    
    virtual void ProcessMessage( const osc::ReceivedMessage& m,
                                const IpEndpointName& remoteEndpoint )
    {
        (void) remoteEndpoint; // suppress unused parameter warning
        
        try{
            const char *msgPattern = m.AddressPattern();
            NSString *oscStr = [NSString stringWithCString:msgPattern encoding:NSUTF8StringEncoding];
            
            int argCount = m.ArgumentCount();
            NSMutableArray *argsArr = [[NSMutableArray alloc] initWithCapacity:argCount];
            
            osc::ReceivedMessage::const_iterator arg = m.ArgumentsBegin();
            while(arg != m.ArgumentsEnd()){
                
                if (arg->IsBool()) {
                    bool bolVal = arg->AsBool();
                    if(bolVal){
                        NSDictionary* argDict = @{@"BOOL":[NSNumber numberWithBool:YES]};
                        [argsArr addObject:argDict];
                    }else{
                        NSDictionary* argDict = @{@"BOOL":[NSNumber numberWithBool:NO]};
                        [argsArr addObject:argDict];
                    }
                    
                    arg++; continue;
                }
                
                if (arg->IsInt32()){
                    int iVal = arg->AsInt32();
                    NSDictionary* argDict = @{@"INT":[NSNumber numberWithFloat:iVal]};
                    [argsArr addObject:argDict];
                    
                    arg++; continue;
                }
                
                if (arg->IsInt64()){
                    long lVal = arg->AsInt64();
                    NSDictionary* argDict = @{@"LONG":[NSNumber numberWithFloat:lVal]};
                    [argsArr addObject:argDict];
                    
                    arg++; continue;
                }
                
                if(arg->IsFloat()){
                    float fVal = arg->AsFloat();
                    NSDictionary* argDict = @{@"FLOAT":[NSNumber numberWithFloat:fVal]};
                    [argsArr addObject:argDict];
                    
                    arg++; continue;
                }
                
                if(arg->IsString()){
                    const char* strVal = arg->AsString();
                    NSDictionary* argDict = @{@"STRING":[NSString stringWithCString:strVal encoding:NSUTF8StringEncoding]};
                    [argsArr addObject:argDict];
                    
                    arg++; continue;
                }
                
                if(arg->IsTimeTag()){
                    uint64 tmTag = arg->AsTimeTag();
                    NSDictionary* argDict = @{@"TIMETAG":[NSNumber numberWithUnsignedLong:tmTag]};
                    [argsArr addObject:argDict];
                    
                    arg++; continue;
                }
                
                if(arg->IsBlob()){
                    
                    const void *data = NULL;
                    long size = -1;
                    arg->AsBlob(data, size);
                    
                    if(data != NULL && size > 0){
                        NSData *dataParam = [NSData dataWithBytes:data length:size];
                        NSDictionary* argDict = @{@"BLOB": dataParam};
                        [argsArr addObject:argDict];
                    }
                    
                    arg++; continue;
                }
                
                //we ignore other cases now
                arg++; continue;
            }
            
            if (g_OSCMonitor != nil) {
                if ([g_OSCMonitor.delegate respondsToSelector:@selector(parsedOscMsg:withParameters:)]) {
                    [g_OSCMonitor.delegate parsedOscMsg:oscStr withParameters:argsArr];
                }
            }
            
        }catch( osc::Exception& e ){
            // any parsing errors such as unexpected argument types, or
            // missing arguments get thrown as exceptions.
            std::cout << "error while parsing message: "
            << m.AddressPattern() << ": " << e.what() << "\n";
        }
    }
};


@interface AMOSCMonitor()
@property int port;
@end

@implementation AMOSCMonitor
{
    int _port;
    UdpListeningReceiveSocket *_listenSocket;
    OSCPacketParser* _oscParser;
}


+(id)monitorWithPort:(int)port
{
    if(g_OSCMonitor == nil){
        g_OSCMonitor = [[AMOSCMonitor alloc] init];
        g_OSCMonitor.port = port;
    }
    
    return g_OSCMonitor;
}

+(AMOSCMonitor *)shareMonitor
{
    return g_OSCMonitor;
}


-(BOOL)startListening
{
    _oscParser = new OSCPacketParser();
    _listenSocket = new UdpListeningReceiveSocket( IpEndpointName(IpEndpointName::ANY_ADDRESS, self.port), _oscParser);
    
    if(_oscParser == NULL || _listenSocket == NULL){
        return NO;
    }
    
    _listenSocket->RunUntilSigInt();
    return YES;
}


-(void)stopListening
{
    if(_listenSocket)
    {
        _listenSocket->Break();
        delete _listenSocket;
        _listenSocket = NULL;
    }
    
    if(_oscParser){
        delete _oscParser;
        _oscParser = NULL;
    }
    
}


-(void)dealloc
{
    [self stopListening];
}

@end
