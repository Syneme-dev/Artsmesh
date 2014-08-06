//
//  AMNetworkToolsCommand.h
//  DemoUI
//
//  Created by lattesir on 8/5/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMNetworkToolsCommand : NSObject

@property (nonatomic) NSString *command;
@property (nonatomic) NSTextView *contentView;

- (void)stop;
- (void)run;

@end
