//
//  AMVideoConfig.h
//  Artsmesh
//
//  Created by whiskyzed on 12/3/15.
//  Copyright © 2015 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMCoreData/AMCoreData.h"

extern NSString* const AMVideoDeviceNotification;

@interface AMVideoConfig : NSObject
@property NSArray*      peer;
@property NSString*     peerIP;
@property int           peerPort;
@property AMLiveUser*   myself;
// AMUser

//-s, --server                             Run in Server Mode
//-c, --client      <peer_host_IP_number>  Run in Client Mode
@property NSString* role;

//if client ip address
@property NSString* serverAddr;

//-o, --portoffset  #                      Receiving port offset from base port 4464
@property NSString* portOffset;

//-n, --numchannels #                      Number of Input and Output Channels (default 2)
@property NSString* channelCount;

//-q, --queue       # (1 or more)          Queue Buffer Length, in Packet Size (default 4)
@property NSString* qCount;

//-r, --redundancy  # (1 or more)          Packet Redundancy to avoid glitches with packet losses (defaul 1)
@property NSString* rCount;

//-b, --bitres      # (8, 16, 24, 32)      Audio Bit Rate Resolutions (default 16)
@property NSString* bitrateRes;

//--clientname                             Change default client name (default is JackTrip)
@property NSString* clientName;

//--ipv6                                   User Ipv6 Protocol
@property BOOL useIpv6;
@end
