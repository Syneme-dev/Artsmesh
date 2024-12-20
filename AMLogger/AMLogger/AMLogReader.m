//
//  AMLogReader.m
//  AMLogger
//
//  Created by WhiskyZed on 10/24/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMLogReader.h"
#import "AMLogger.h"

static const NSInteger kBufferSize = 4096 * 4;   // 16k

NSString* const AMJacktripWaitNotification     = @"AMJacktripWaitNotification";
NSString* const AMJacktripConnectNotification  = @"AMJacktripConnectNotification";
NSString* const AMJacktripStopNotification     = @"AMJacktripStopNotification";

NSString* const connectMsg  = @"Received Connection from Peer";
NSString* const waitMsg     = @"Waiting for Peer";
NSString* const stopMsg     = @"Shutting Down";

@interface AMLogReader()
{
    FILE *_logFile;
    char *_buffer;
}

@end

@implementation AMLogReader

+ (instancetype)logReaderByType:(NSString *)type
{
    AMLogReader *logReader = [[self alloc] initWithFileName:kAMDefaultLogFile];
    logReader.filter = ^(NSString *line) {
        if (type == kAMInfoLog) {
            return YES;
        }
        
        return [line hasPrefix:type];
    };
    return logReader;
}

+ (instancetype)errorLogReader
{
    return [self logReaderByType:kAMErrorLog];
}

+ (instancetype)warningLogReader
{
    return [self logReaderByType:kAMWarningLog];
}

+ (instancetype)infoLogReader
{
    return [self logReaderByType:kAMInfoLog];
}

- (instancetype)initWithFileName:(NSString *)logFileName
{
    self = [super init];
    if (self) {
        NSString *logDirectory = AMLogDirectory();
        NSString *logFilePath = [logDirectory stringByAppendingPathComponent:logFileName];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:logFilePath])
            return nil;
        _logFile = fopen([logFilePath cStringUsingEncoding:NSUTF8StringEncoding], "r");
        if (!_logFile)
            return nil;
        _buffer = NULL;
    }
    return self;
}

- (Boolean) resetLog
{
    if(_logFile == nil)
        return NO;
    fseek(_logFile, 0, SEEK_SET);
    
    return YES;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName:@"InvalidInitializerException"
                                   reason:@"use initWithFileName:"
                                 userInfo:nil];
}

- (void)dealloc
{
    fclose(_logFile);
    free(_buffer);
}

- (NSArray *)lastLogItmes
{
    off_t endpos, offset;
    size_t nbytes;
    
    if (fseeko(_logFile, 0, SEEK_END) != 0)
        return nil;
    
    endpos = ftello(_logFile);
    if (endpos == -1)
        return nil;
    
    if (!_buffer) {
        _buffer = malloc(kBufferSize);
        if (!_buffer)
            return nil;
    }
    
    offset = endpos - MIN(endpos, kBufferSize - 1);
    nbytes = pread(fileno(_logFile), _buffer, kBufferSize - 1, offset);
    _buffer[nbytes] = 0;
    
    NSString *logText = [NSString stringWithUTF8String:_buffer];
    NSMutableArray *logRecords = [NSMutableArray array];
    [logText enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
        if (self.filter) {
            if (self.filter(line))
                [logRecords addObject:line];
        } else
            [logRecords addObject:line];
    }];
    return logRecords;
}

-(NSString*)nextLogItem
{
    char line[1024];
    
    if (feof(_logFile))
        clearerr(_logFile);
    
    if (fgets(line, sizeof(line), _logFile) == NULL)
        return nil;
    
    return [NSString stringWithUTF8String:line];
}

- (void)sendStateNotification
{
    [self resetLog];
    NSString *fullLog = [[NSString alloc] init];
    NSString *logItem = nil;
    while((logItem = [self nextLogItem]) != nil){
        fullLog = [fullLog stringByAppendingString:logItem];
    }
    
    NSRange waitRange       = [fullLog rangeOfString:waitMsg        options:NSBackwardsSearch];
    NSRange connectRange    = [fullLog rangeOfString:connectMsg     options:NSBackwardsSearch];
    NSRange stopRange       = [fullLog rangeOfString:stopMsg        options:NSBackwardsSearch];
    
    if(stopRange.length > 0)
    {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:AMJacktripStopNotification
         object:self];
    }
    else if(connectRange.length > 0)
    {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:AMJacktripConnectNotification
         object:self];
    }
    else if(waitRange.length > 0)
    {
        [[NSNotificationCenter defaultCenter]
         postNotificationName:AMJacktripWaitNotification
         object:self];
    }
}
@end


@implementation AMSystemLogReader

@end
