//
//  AMStatusNetModule.m
//  AMStatusNetModule
//
//  Created by Wei Wang on 5/7/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMStatusNetModule.h"

@implementation AMStatusNetModule
{
    NSTask *_task;
    NSFileHandle *_pipeIn;
    NSString* _result;
}


-(BOOL)postMessageToStatusNet:(NSString*)status
                   urlAddress:(NSString*)url
                 withUserName:(NSString*)username
                 withPassword:(NSString*)password
{
    //curl -m 10 -u wangwei:wangwei1982 'http://syneme-asia.ccom.edu.cn/statusnet/index.php/api/statuses/update.xml'  -d status='xxxxcccc'  -D /dev/stdout -o /dev/null 2>/dev/null | head -1 | awk '{print $2}'
    
    NSString* commandStr = [NSString stringWithFormat:@"curl -m 10 -u %@:%@ \'%@/api/statuses/update.xml\'  -d status=\'%@\'  -D /dev/stdout -o /dev/null 2>/dev/null | head -1 | awk '{print $2}'", username, password, url, status];
    
    return [self runTask:commandStr];
}

- (void)cancelTask
{
    if (_task) {
        @try {
            _pipeIn.readabilityHandler = nil;
            [_task interrupt];
        }
        @catch (NSException *exception) {
            // ignore
        }
        @finally {
            _task = nil;
            _pipeIn = nil;
        }
    }
}

-(BOOL)runTask:(NSString *)command
{
    [self cancelTask];
    
    _task = [[NSTask alloc] init];
    _task.launchPath = @"/bin/bash";
    _task.arguments = @[@"-c", command];
    
    NSPipe *pipe = [NSPipe pipe];
    _task.standardOutput = pipe;
    _task.standardError = pipe;
    [_task launch];
    
    _pipeIn = [pipe fileHandleForReading];
    NSData *data = [_pipeIn readDataToEndOfFile];
    NSString* result = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if([result isEqualToString:@"200\n"])
    {
        return YES;
    }
    
    return NO;
}




@end
