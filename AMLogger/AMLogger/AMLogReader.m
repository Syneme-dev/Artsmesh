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

//+ (instancetype)debugLogReader
//{
//    return [self logReaderByType:kAMDebugLog];
//}

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

@end


@implementation AMSystemLogReader

@end