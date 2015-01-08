//
//  AMLogger.m
//  AMLogger
//
//  Created by Sky JIA on 12/30/13.
//  Copyright (c) 2013 Artsmesh. All rights reserved.
//

#import "AMLogger.h"

NSString * const kAMDefaultLogFile = @"artsmesh.log";

NSString * const kAMErrorLog = @"ERROR";
NSString * const kAMWarningLog = @"WARN";
NSString * const kAMInfoLog = @"INFO";


NSString * const kAMOSCServerTitle  = @"OSC SERVER";
NSString * const kAMOSCClientTitle  = @"OSC CLIENT";
NSString * const kAMJackAudioTitle  = @"JACK AUDIO";
NSString * const kAMAMServerTitle   = @"AMSERVER";
NSString * const kAMArtsmeshTitle   = @"ARTSMESH";


NSString * const kAMOSCServerFile   = @"OSC_Server.log";
NSString * const kAMOSCClientFile   = @"OSC_Client.log";
NSString * const kAMJackAudioFile   = @"Jack_Audio.log";
NSString * const kAMAMServerFile    = @"AMServer.log";
NSString * const kAMArtsmeshFile    = @"Artsmesh.log";
NSString * const kAMJackTripFile    = @"Jacktrip";

//NSString * const kAMDebugLog = @"DEBUG";

static FILE *logFile;

NSString *
AMLogDirectory(void)
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    assert(paths.count == 1);
    NSString *logsDirecotry = [paths[0] stringByAppendingPathComponent:@"Logs"];
    return [logsDirecotry stringByAppendingPathComponent:@"Artsmesh"];
}

BOOL
AMLogInitialize(void)
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *logDirectory = AMLogDirectory();
    BOOL isDirectory;
    
    if (![fileManager fileExistsAtPath:logDirectory isDirectory:&isDirectory]) {
        isDirectory = [fileManager createDirectoryAtPath:logDirectory
                             withIntermediateDirectories:NO
                                              attributes:nil
                                                   error:nil];
    }
    
    if (isDirectory) {
        NSString *logDirectory = AMLogDirectory();
        
        
        //先将要创建log文件完整路径全部写到NSArray
        NSMutableArray*  logFiles = [NSMutableArray arrayWithCapacity:4];
        [logFiles addObject:[logDirectory stringByAppendingPathComponent:kAMOSCServerFile]];
        [logFiles addObject:[logDirectory stringByAppendingPathComponent:kAMOSCClientFile]];
        [logFiles addObject:[logDirectory stringByAppendingPathComponent:kAMJackAudioFile]];
        [logFiles addObject:[logDirectory stringByAppendingPathComponent:kAMAMServerFile]];
        
        for (NSString* logPath in logFiles) {
            if(![fileManager fileExistsAtPath:logPath])
            {
                [fileManager createFileAtPath:logPath
                                     contents:nil
                                   attributes:nil];
            }
        }
    
        //再把Artsmesh.log更名为prev_Artsmesh.log文件
        NSString *prevLogFile = [NSString stringWithFormat:@"prev_%@", kAMDefaultLogFile];
        NSString *logFilePath = [logDirectory stringByAppendingPathComponent:kAMDefaultLogFile];
        NSString *previousLogFilePath = logFilePath;//[logFilePath stringByAppendingString:@"~previous"];
        if ([fileManager fileExistsAtPath:logFilePath]) {
            [fileManager moveItemAtPath:logFilePath
                                 toPath:previousLogFilePath
                                  error:nil];
        }
        if ([fileManager createFileAtPath:logFilePath contents:nil attributes:nil]) {
            logFile = fopen([logFilePath cStringUsingEncoding:NSUTF8StringEncoding], "a");
            setvbuf(logFile, NULL, _IOLBF, 0);
            return logFile != NULL;
        }
    }
    
    return NO;
}


void
AMLogClose(void)
{
    if (logFile) {
        fclose(logFile);
        logFile = NULL;
    }
}

void
AMLog(NSString *level, NSString *module, NSString *format, ...)
{
    assert(logFile);
    
    va_list ap;
    NSString *message = @"";
    
    if (format) {
        va_start(ap, format);
        message = [[NSString alloc] initWithFormat:format arguments:ap];
        va_end(ap);
    }
    
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    
    NSString *logRecord = [NSString stringWithFormat:@"%@:[%@]:[%@]:%@",
                                level, localeDate, module, message];
    fprintf(logFile, "%s\n", [logRecord cStringUsingEncoding:NSUTF8StringEncoding]);
}

