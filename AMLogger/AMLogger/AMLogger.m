//
//  AMLogger.m
//  AMLogger
//
//  Created by Sky JIA on 12/30/13.
//  Copyright (c) 2013 Artsmesh. All rights reserved.
//

#import "AMLogger.h"

NSString * const kAMErrorLog = @"ERROR";
NSString * const kAMWarningLog = @"WARN";
NSString * const kAMInfoLog = @"INFO";
NSString * const kAMDebugLog = @"DEBUG";

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
        NSString *logFilePath = [logDirectory stringByAppendingPathComponent:@"artsmesh.log"];
        NSString *previousLogFilePath = [logFilePath stringByAppendingString:@"~previous"];
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
    
    NSString *logRecord = [NSString stringWithFormat:@"%@:[%@]:[%@]:%@",
                                level, [NSDate date], module, message];
    fprintf(logFile, "%s\n", [logRecord cStringUsingEncoding:NSUTF8StringEncoding]);
}

