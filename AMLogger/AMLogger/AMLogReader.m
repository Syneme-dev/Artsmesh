//
//  AMLogReader.m
//  AMLogger
//
//  Created by WhiskyZed on 10/24/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMLogReader.h"

@implementation AMLogReader
{
    NSString*           logFullPath;
    NSMutableArray*     logArray;
}
@synthesize logCountFromTail;

-(id) initLogReader:(NSString*) newLogFullPath{
    //Open File
    logFullPath = newLogFullPath;
    return nil;
}

-(BOOL) openLastSomeLogs
{
    if(logFullPath)
    {
        //Open a log file
        //Save to logArray instance varible.
        return YES;
    }
    else
        return NO;
}

-(NSMutableArray*) logArray
{
    return logArray;
}

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
@end


@implementation AMErrorLogReader
-(id) initErrorLogReader{
    NSString* logDir = [NSString stringWithFormat:@"%@/%@", [AMLogger AMLogPath], @"AMLog.log"];
    return [super initLogReader:logDir];
}

@end



@implementation AMSystemLogReader
-(id) initSystemLogReader:(NSString*)fullPath
{
    return [super initLogReader:fullPath];
}

@end