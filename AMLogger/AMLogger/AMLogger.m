//
//  AMLogger.m
//  AMLogger
//
//  Created by Sky JIA on 12/30/13.
//  Copyright (c) 2013 Artsmesh. All rights reserved.
//

#import "AMLogger.h"
#import <Foundation/NSPathUtilities.h>

static AMLogger* _sharedInstance = nil;
const NSString* _logRelativeFolderName = @"/Log";
const NSString* _logName = @"AMLog.log";

@implementation AMLogger
{
    NSString* _logFilePath;
    NSFileHandle* _logFileHandle;
}

+(void)AMLoggerInit
{
    @synchronized(_sharedInstance){
        if (_sharedInstance == nil) {
            _sharedInstance = [[AMLogger alloc] init];
        }
        [_sharedInstance openLogger:YES];
    }
}


+(void)AMLoggerRelease
{
    [_sharedInstance closeLogger];
}

+(NSString*)AMLogPath
{
    NSString* bundlePath = [[NSBundle mainBundle] bundlePath];
    if ([bundlePath hasSuffix:@".app"]) {
        [bundlePath stringByDeletingLastPathComponent];
    }
    
    return bundlePath;
}

+(NSString*)AMLoggerName
{
    NSString* logName = [NSString stringWithFormat:@"%@", _logName];
    return logName;
}


-(void)openLogger:(BOOL)trunc
{
    if (_logFileHandle == nil) {
        NSFileManager *fm = [NSFileManager defaultManager];
        
        NSString* bundlePath = [AMLogger AMLogPath];
        NSString* logName = [AMLogger AMLoggerName];
        _logFilePath = [NSString stringWithFormat:@"%@/%@", bundlePath, logName];
        if (trunc) {
            NSError* err;
            [fm removeItemAtPath:_logFilePath error:&err];
        }
        
        BOOL logFileExist = [fm createFileAtPath:_logFilePath contents:nil attributes:nil];
        
        if (logFileExist) {
            _logFileHandle  = [NSFileHandle fileHandleForWritingAtPath:_logFilePath];
        }
        
        NSLog(@"log file is located: %@", _logFilePath);
    }
}


-(void)closeLogger
{
    if(_logFileHandle){
        [_logFileHandle closeFile];
        _logFileHandle = nil;
    }
}


-(void)writeLogCategory:(AMLogCategory) cat module:(NSString*) module content:(NSString*)content;
{
    if(_logFileHandle){
        NSString* logItem = [NSString stringWithFormat:@"%@:[%@]:[%@]:%@\n",
                             [AMLogger AMLogCategoryToString:cat],
                             [NSDate date],
                             module,
                             content
                             ];
        NSLog(@"%@", logItem);
        [_logFileHandle writeData: [logItem dataUsingEncoding:NSUTF8StringEncoding]];
    }
}


+ (NSString*)AMLogCategoryToString:(AMLogCategory)cat{
    NSString *result = nil;
    switch(cat) {
        case AMLog_Error:
            result = @"ERROR:";
            break;
        case AMLog_Warning:
            result = @"WARNING:";
            break;
        case AMLog_Debug:
            result = @"DEBUG:";
            break;
        default:
            result = @"Unkown";
    }
    return result;
}

@end


void AMLog(AMLogCategory cat, NSString* module, NSString* format, ...)
{
    va_list list;
    va_start(list, format);
    NSString *logStr = [[NSString alloc] initWithFormat:format arguments:list];
    va_end(list);
    
    if (_sharedInstance) {
        [_sharedInstance writeLogCategory:cat module:module content:logStr];
    }
}


