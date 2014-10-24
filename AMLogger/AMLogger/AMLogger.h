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

//.Artsmesh.app/../Log/
+(NSString*)AMLogPath;


-(void)registerViewer:(id<AMLoggerViewer>)viewer forCategory:(AMLogCategory)cat;
-(void)unregisterViewer:(id<AMLoggerViewer>)viewer;

//backFromIndex: retrieve log from the latest. the latest log item is index 0;
//count: how many items of log you want to get, max 5000
//if there are not so much logs, will return the actual count
-(NSArray*)readLogCategory:(AMLogCategory)cat backFromIndex:(long)index count:(long)count;

@end


@protocol AMLoggerViewer <NSObject>

-(void)addLog:(AMLoggerStruct*)logData;

@end
