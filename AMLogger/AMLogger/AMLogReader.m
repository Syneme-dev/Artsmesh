//
//  AMLogReader.m
//  AMLogger
//
//  Created by WhiskyZed on 10/24/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMLogReader.h"
#import "AMLogger.h"
#import "NSFileHandle+readLine.h"
/*
 //Error按钮实现代码
 
 AMLogReader* reader = [[AMErrorLogReader alloc] initErrorLogReader];
 if([reader openLastSomeLogs] == YES)
 {
 NSMutableArray* logArray = [reader logArray];
 }
 */

/*
 //System按钮实现代码
 //利用coco框架，打开文件对话框，获取文件路径
 NSString* fullPath = [...]
 AMSystemLogReader* reader
 AMSystemLogReader* reader = [[AMSystemLogReader alloc] initSystemLogReader];
 if([reader openLastSomeLogs] == YES)
 {
 NSMutableArray* logArray = [reader logArray];
 }
 */

/*
 //打开文件全部内容
 AMLogReader* reader = [[AMErrorLogReader alloc] initErrorLogReader];
 NSString* logItem = [reader nextLogItem];
 
 while(logItem)
 {
 [view appendString:logItem];
 }
 */

@interface AMLogReader()

@property NSFileHandle* logFileHandle;

@end


@implementation AMLogReader
{
    NSString*    _logFullPath;
    NSArray*     _logArray;
    
    NSFileHandle* _fileHandle;
    
}

@synthesize logCountFromTail;

-(id)initWithFileName:(NSString*)logFilePath{
    if (self = [super init]) {
        _logFullPath = logFilePath;
        
        NSFileManager* fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:logFilePath]) {
            [fm createFileAtPath:logFilePath contents:nil attributes:nil];
        }
        
        _fileHandle = [NSFileHandle fileHandleForReadingAtPath:logFilePath];
        if (_fileHandle == nil){
            return nil;
        }
    }

    return self;
}

-(NSString* )filterLog:(NSData*)logData
{
     return [[NSString alloc] initWithData:logData encoding:NSUTF8StringEncoding];
}

-(NSArray*)lastLogItmes
{
    NSMutableArray* logs = [[NSMutableArray alloc] init];
    
    if(_fileHandle){
        unsigned long long fileSize = [self logSize];
        unsigned long long bufferSize = 1024*1024;
        
        if (bufferSize > fileSize) {
            [_fileHandle seekToFileOffset:0];
        }else{
            [_fileHandle seekToFileOffset:fileSize - bufferSize];
        }
        
        
        NSData* logData = [_fileHandle readLineWithDelimiter:@"\n"];
        while (logData != nil) {
            NSString* logStr = [self filterLog:logData];
            [logs addObject:logStr];
            
            logData =  [_fileHandle readLineWithDelimiter:@"\n"];
        }
    }
    
    return logs;
}

-(NSString*)nextLogItem
{
    NSData* logData = [_fileHandle readLineWithDelimiter:@"\n"];
    while (logData != nil) {
        NSString* logStr = [self filterLog:logData];
        if (logStr == nil) {
            continue;
        }else{
            return logStr;
        }
    }
    
    return nil;
}


-(unsigned long long)logSize
{
    unsigned long long fileSize = -1;
    NSFileManager* fm = [NSFileManager defaultManager];
    NSDictionary* fileAttr = [fm attributesOfItemAtPath:_logFullPath error:nil];
    if(fileAttr!=nil){
        fileSize = [[fileAttr objectForKey:NSFileSize] unsignedLongLongValue];
    }
    
    return fileSize;
}

@end


@implementation AMErrorLogReader

-(id) init{
    NSString* logName = [AMLogger AMLoggerName];
    NSString* logPath = [AMLogger AMLogPath];
    NSString* logDir = [NSString stringWithFormat:@"%@/%@", logPath, logName];
    self = [super initWithFileName:logDir];
    return self;
}

-(NSArray *)logArray{
    NSArray* logArray = @[@"error log1", @"error log2", @"error log3"];
    return logArray;
}

@end

@implementation AMWarningLogReader
-(id) init{
    NSString* logName = [AMLogger AMLoggerName];
    NSString* logPath = [AMLogger AMLogPath];
    NSString* logDir = [NSString stringWithFormat:@"%@/%@", logPath, logName];
    self = [super initWithFileName:logDir];
    return self;
}

-(NSArray *)logArray{
    NSArray* logArray = @[@"Warning log1", @"Warning log2", @"Warning log3"];
    return logArray;
}


@end

@implementation AMInfoLogReader

-(id) init{
    NSString* logName = [AMLogger AMLoggerName];
    NSString* logPath = [AMLogger AMLogPath];
    NSString* logDir = [NSString stringWithFormat:@"%@/%@", logPath, logName];
    self = [super initWithFileName:logDir];
    return self;
}

-(NSArray *)logArray{
    NSArray* logArray = @[@"Info log1", @"Info log2", @"Info log3"];
    return logArray;
}

@end


@implementation AMSystemLogReader

-(id)initWithFileName:(NSString*)logFilePath{
    self = [super initWithFileName:logFilePath];
    return self;
}

@end