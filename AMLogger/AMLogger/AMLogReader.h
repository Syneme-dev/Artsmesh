//
//  AMLogReader.h
//  AMLogger
//
//  Created by WhiskyZed on 10/24/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const AMJacktripWaitNotification;
extern NSString * const AMJacktripConnectNotification;
extern NSString * const AMJacktripStopNotification;

@interface AMLogReader : NSObject

@property(nonatomic, copy) BOOL (^filter)(NSString *line);

// designated initializer
- (instancetype)initWithFileName:(NSString *)logFileName;
- (NSArray *)lastLogItmes;
- (NSString *)nextLogItem;

- (Boolean) resetLog;

- (void )sendStateNotification;

@end


@interface  AMSystemLogReader : AMLogReader
@end
