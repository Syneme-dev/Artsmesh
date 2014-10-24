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

-(id)           initWithLogFullPath:(NSString*)logFile;
-(BOOL)         openLogFromTail;
-(NSArray*)     logArray;
-(NSString*)    nextLogItem;

@end



@interface AMErrorLogReader : AMLogReader
-(id) initErrorLogReader;
@end


@interface  AMSystemLogReader : AMLogReader

@end