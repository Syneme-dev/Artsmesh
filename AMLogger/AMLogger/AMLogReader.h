//
//  AMLogReader.h
//  AMLogger
//
//  Created by WhiskyZed on 10/24/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMLogReader : NSObject

@property(nonatomic, copy) BOOL (^filter)(NSString *line);

// designated initializer
- (instancetype)initWithFileName:(NSString *)logFileName;
- (NSArray *)lastLogItmes;
- (NSString *)nextLogItem;

- (Boolean) resetLog;

@end


@interface  AMSystemLogReader : AMLogReader
@end