//
//  AMLogReader.m
//  AMLogger
//
//  Created by WhiskyZed on 10/24/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMLogReader.h"
#import "AMLogger.h"
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

@implementation AMLogReader
{
    NSString*           logFullPath;
    NSMutableArray*     logArray;
}

@synthesize logCountFromTail;

-(id) initLogReader:(NSString*) newLogFullPath{
    if (self = [super init]) {
        logFullPath = newLogFullPath;
    }

    return self;
}

-(BOOL) openLogFromTail
{
    return YES;
}

-(NSArray*)logArray{
    return nil;
}


-(NSString*) nextLogItem
{
    return @"do not call base class method!";
}

@end


@implementation AMErrorLogReader

-(id) initErrorLogReader{
    
    NSString* logName = [AMLogger AMLoggerName];
    NSString* logPath = [AMLogger AMLogPath];
    NSString* logDir = [NSString stringWithFormat:@"%@/%@", logPath, logName];
    self = [super initLogReader:logDir];
    return self;
}

-(NSArray *)logArray{
    NSArray* logArray = @[@"error log1", @"error log2", @"error log3"];
    return logArray;
}

@end



@implementation AMSystemLogReader
-(id) initSystemLogReader:(NSString*)fullPath
{
    return [super initLogReader:fullPath];
}

@end