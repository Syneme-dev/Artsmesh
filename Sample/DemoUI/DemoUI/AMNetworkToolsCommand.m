//
//  AMNetworkToolsCommand.m
//  DemoUI
//
//  Created by lattesir on 8/5/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMNetworkToolsCommand.h"
#import "AMTaskLauncher/AMShellTask.h"

#define UI_Color_b7b7b7  [NSColor colorWithCalibratedRed:(168)/255.0f green:(168)/255.0f blue:(168)/255.0f alpha:1.0f]

@implementation AMNetworkToolsCommand
{
    AMShellTask *_task;
}

- (void)stop
{
    if (_task) {
        [_task cancel];
        _task = nil;
        self.contentView.string = @"";
    }
}

- (void)run
{
    if (!self.command)
        return;
    
    _task = [[AMShellTask alloc] initWithCommand:_command];
    [_task launch];
    NSFileHandle *inputStream = [_task fileHandlerForReading];
    inputStream.readabilityHandler = ^ (NSFileHandle *fh) {
        NSData *data = [fh availableData];
        NSString *string = [[NSString alloc] initWithData:data
                                                 encoding:NSUTF8StringEncoding];
        NSDictionary *attr = @{ NSForegroundColorAttributeName : UI_Color_b7b7b7 };
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string
                                                                         attributes:attr];
        [self.contentView.textStorage appendAttributedString:attrString];
        self.contentView.needsDisplay = YES;
    };
}

@end
