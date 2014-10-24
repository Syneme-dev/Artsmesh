//
//  AMLogReader.h
//  AMLogger
//
//  Created by WhiskyZed on 10/24/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMLogger.h"
@interface AMLogReader : NSObject

-(id) initLogReader:(NSString*)proceesName;
@property int logCountFromTail;

-(BOOL)         openLogFromTail;
-(NSArray*)     logArray;
-(NSString*)    nextLogItem;
-(void)         resetReader;
@end



@interface AMErrorLogReader : AMLogReader
-(id) initErrorLogReader;
-(NSString*) nextLogItem;
-(void) resetReader;
@end


@interface  AMSystemLogReader : AMLogReader

@end