//
//  AMLogReader.h
//  AMLogger
//
//  Created by WhiskyZed on 10/24/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AMLogReader : NSObject

@property int logCountFromTail;

-(BOOL)         openLogFromTail;
-(NSArray*)     logArray;
-(NSString*)    nextLogItem;

@end

@interface AMErrorLogReader : AMLogReader
@end

@interface AMWarningLogReader : AMLogReader
@end

@interface AMInfoLogReader : AMLogReader
@end

@interface  AMSystemLogReader : AMLogReader

-(id)initWithFileName:(NSString*)logFilePath;

@end