//
//  AMLogger.h
//  AMLogger
//
//  Created by Sky JIA on 12/30/13.
//  Copyright (c) 2013 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kAMDefaultLogFile;

extern NSString * const kAMErrorLog;
extern NSString * const kAMWarningLog;
extern NSString * const kAMInfoLog;
//extern NSString * const kAMDebugLog;

BOOL AMLogInitialize(void);
void AMLog(NSString *level, NSString *module, NSString *format, ...);
void AMLogClose(void);
NSString *AMLogDirectory(void);


extern NSString * const kAMOSCServerTitle;
extern NSString * const kAMOSCClientTitle;
extern NSString * const kAMJackAudioTitle;
extern NSString * const kAMAMServerTitle;
extern NSString * const kAMArtsmeshTitle;


extern NSString * const kAMOSCServerFile;
extern NSString * const kAMOSCClientFile;
extern NSString * const kAMJackAudioFile;
extern NSString * const kAMAMServerFile;
extern NSString * const kAMArtsmeshFile;
extern NSString * const kAMJackTripFile;