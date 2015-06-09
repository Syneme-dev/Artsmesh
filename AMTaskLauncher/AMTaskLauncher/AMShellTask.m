//
//  AMShellTask.m
//  ShellExecutor
//
//  Created by lattesir on 5/9/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import "AMShellTask.h"

@implementation AMShellTask
{
    NSTask *_task;
    NSPipe *_pipe;
}

- (id)init
{
    return [self initWithCommand:@""];
}

- (instancetype)initWithCommand:(NSString *)command
{
    if (!command)
        return nil;
    
    self = [super init];
    
    if (self) {
        _task = [[NSTask alloc] init];
        _task.launchPath = @"/bin/bash";
        _task.arguments = @[@"-c", [command copy]];
        
        _pipe = [NSPipe pipe];
        [[_pipe fileHandleForReading] waitForDataInBackgroundAndNotify];
        _task.standardOutput = _pipe;
        _task.standardError = _pipe;
        AMShellTask * __weak weakSelf = self;
        _task.terminationHandler = ^(NSTask *unused) {
            [weakSelf cancel];
        };
    }
    return self;
}

- (NSFileHandle *)fileHandlerForReading
{
    return _pipe.fileHandleForReading;
}

- (void)launch
{
    NSAssert(_task, @"Can not lauch a cancelled task");
    [_task launch];
}

- (void)cancel
{
    if (_task) {
        _pipe.fileHandleForReading.readabilityHandler = nil;
        [_task interrupt];
        _task = nil;
        _pipe = nil;
    }
}

- (NSString *)readAllDataAsString
{
    NSData *data = [_pipe.fileHandleForReading readDataToEndOfFile];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

@end
