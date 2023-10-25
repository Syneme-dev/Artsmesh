//
//  AMJacktripConfigs.h
//  AMAudio
//
//  Created by 王 为 on 9/10/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMJacktripConfigs : NSObject

// --rtaudio 
@property NSString* backend;

//-s, --server                             Run in Server Mode
//-c, --client      <peer_host_IP_number>  Run in Client Mode
@property NSString* role;

//if client ip address
@property NSString* serverAddr;

//-o, --portoffset  #                      Receiving port offset from base port 4464
@property NSString* portOffset;

//-n, --numchannels #                      Number of Input and Output Channels (default 2)
@property NSString* channelCount;

//-, --numchannels #                       Counter of recv Channels (default 2)
@property NSString* recvCount;


//-q, --queue       # (1 or more)          Queue Buffer Length, in Packet Size (default 4)
@property NSString* qBufferLen;

//-r, --redundancy  # (1 or more)          Packet Redundancy to avoid glitches with packet losses (defaul 1)
@property NSString* rCount;

//-b, --bitres      # (8, 16, 24, 32)      Audio Bit Rate Resolutions (default 16)
@property NSString* bitrateRes;

//-z, --zerounderrun                       Set buffer to zeros when underrun occurs (defaults to wavetable)
@property BOOL zerounderrun;

//-l, --loopback                           Run in Loop-Back Mode
@property BOOL loopback;

//-j, --jamlink                            Run in JamLink Mode (Connect to a JamLink Box)
@property BOOL jamlink;

//--clientname                             Change default client name (default is JackTrip)
@property NSString* clientName;

//--ipv6                                   User Ipv6 Protocol
@property BOOL useIpv6;

@end
