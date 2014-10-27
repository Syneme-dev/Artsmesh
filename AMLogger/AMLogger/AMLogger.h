//
//  AMLogger.h
//  AMLogger
//
//  Created by Sky JIA on 12/30/13.
//  Copyright (c) 2013 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol AMLoggerViewer;

typedef enum {
    AMLog_Error,
    AMLog_Warning,
    AMLog_Debug,
    AMLog_System,
    
}AMLogCategory;


@interface AMLoggerStruct : NSObject

@property NSString* happenModuleName;
@property AMLogCategory* category;
@property NSString* content;
@property NSDate* timestamp;

@end


void AMLog(AMLogCategory cat, NSString* module, NSString* format, ...);


@interface AMLogger : NSObject

+(void)AMLoggerInit;
+(void)AMLoggerRelease;

+(NSString*)AMLoggerName;
+(NSString*)AMLogPath;
+(NSArray*)allLogNames;

@end


@protocol AMLoggerViewer <NSObject>

-(void)addLog:(AMLoggerStruct*)logData;

@end
