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

- (id) init
{
    if (self = [super init]) {
        NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self
               selector:@selector(handleReadingData:)
                   name:NSFileHandleDataAvailableNotification
                 object:nil];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
}

- (void) handleReadingData : (NSNotification*)noti
{
    NSData* data = [[_task fileHandlerForReading] availableData];
    NSString *string = [[NSString alloc] initWithData:data
                                             encoding:NSUTF8StringEncoding];
    NSDictionary *attr = @{ NSForegroundColorAttributeName : UI_Color_b7b7b7 };
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string
                                                                         attributes:attr];
    [self.contentView.textStorage appendAttributedString:attrString];
    self.contentView.needsDisplay = YES;
    
   
}
@end
