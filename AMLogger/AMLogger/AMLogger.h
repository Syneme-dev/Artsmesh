//
//  AMLogger.h
//  AMLogger
//
//  Created by Sky JIA on 12/30/13.
//  Copyright (c) 2013 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kAMErrorLog;
extern NSString * const kAMWarningLog;
extern NSString * const kAMInfoLog;
extern NSString * const kAMDebugLog;

BOOL AMLogInitialize(void);
void AMLog(NSString *level, NSString *module, NSString *format, ...);
void AMLogClose(void);
NSString *AMLogFilePath(void);
