//
//  AMOSCForwarder.m
//  AMOSCGroups
//
//  Created by wangwei on 29/12/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

//#include <cstring>
//#include <iostream>
//#include <vector>
//#include <ctime>
//#include <string>
//#include <cassert>
//#include <cstdlib>
#include "UdpSocket.h"

//    void PreparePingBuffer()
//    {
////        osc::OutboundPacketStream p( pingBuffer_, IP_MTU_SIZE );
////        
////        p << osc::BeginBundle();
////        
////        p << osc::BeginMessage( "/groupclient/ping" )
////       // << userName_.c_str()
////        << osc::EndMessage;
////        
////        p << osc::EndBundle;
////        
////        pingSize_ = p.Size();
//    }
//    
//    void SendPing( IpEndpointName& to, std::time_t currentTime )
//    {
////        char addressString[ IpEndpointName::ADDRESS_AND_PORT_STRING_LENGTH ];
////        to.endpointName.AddressAndPortAsString( addressString );
////        
////        std::cout << "sending ping to " << addressString << "\n";
////        
////        externalSocket_.SendTo( to.endpointName, pingBuffer_, pingSize_ );
////        ++to.sentPingsCount;
////        to.lastPingSendTime = currentTime;
//    }



#import "AMOSCForwarder.h"
#import "AMLogger/AMLogger.h"

@implementation AMOSCForwarder
{
    
}


-(instancetype)init
{
    if(self = [super init]){
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
}



@end
