//
//  AMLogReader.h
//  AMLogger
//
//  Created by WhiskyZed on 10/24/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMLogReader : NSObject

+ (instancetype)errorLogReader;
+ (instancetype)warningLogReader;
+ (instancetype)infoLogReader;
+ (instancetype)debugLogReader;

@property(nonatomic, copy) BOOL (^filter)(NSString *line);

// designated initializer
- (instancetype)initWithFileName:(NSString *)logFilePath;
- (NSArray *)lastLogItmes;
- (NSString *)nextLogItem;

@end


@interface  AMSystemLogReader : AMLogReader
@end