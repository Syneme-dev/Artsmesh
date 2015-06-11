//
//  AMShellTask.h
//  ShellExecutor
//
//  Created by lattesir on 5/9/14.
//  Copyright (c) 2014 Big Nerd Ranch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMShellTask : NSObject

// designated initializer
- (instancetype)initWithCommand:(NSString *)command;
- (void)launch;
- (void)cancel;
- (NSFileHandle *)fileHandlerForReading;
// utility method
- (NSString *)readAllDataAsString;

- (void) waitForDataAndNotify;

@end
