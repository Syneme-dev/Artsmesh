//
//  AMJackConfigs.h
//  AMAudio
//
//  Created by 王 为 on 8/22/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMJackConfigs : NSObject

@property NSString* driver;
@property NSString* inputDevUID;
@property NSString* outputDevUID;
@property int sampleRate;
@property int bufferSize;
@property int inChansCount;
@property int outChansCount;

//parameters of jack server
@property BOOL hogMode; //if hogmode is true you can't change the preference
@property BOOL clockDriftCompensation; //if device is duplex, false and disable it
@property BOOL systemPortMonitoring; //-m parameter in commandline
@property BOOL activeMIDI; //-X parameter in commandline

//parameters of jack router
@property int interfaceInputChannel;
@property int interfaceOutputChannel;
@property int virtualInputChannel;
@property int virtualOutputChannel;
@property BOOL autoConnectWithPhyicalPorts;
@property BOOL verboseLoggingForDebugPurpose;

-(NSString*)formatCommandLine;

+(id)initWithArchiveConfig;
-(void)archiveConfigs;


@end
