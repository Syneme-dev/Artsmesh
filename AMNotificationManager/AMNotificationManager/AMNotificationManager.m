//
//  AMNotificationManager.m
//  AMNotificationManager
//
//  Created by Sky JIA on 12/30/13.
//  Copyright (c) 2013 Artsmesh. All rights reserved.
//

#import <AMPreferenceManager/AMPreferenceManager.h>
#import "AMNotificationManager.h"

static id sharedManager = nil;

@implementation AMNotificationManager

+(AMNotificationManager *)defaultShared{
    return sharedManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self defaultShared];
}

- (id)init
{
    return sharedManager;
}

+ (void)initialize
{
    if (self == [AMNotificationManager class])
    {
        sharedManager = [[self alloc] init];
    }
}

//-(void)registerMessageTypeWithName:(NSString*)typeName sender:(id)sender{
//    
//}
//-(void)unregisterMessageTypeWithName:(NSString*)typeName sender:(id)sender{
//    
//}
-(void)listenMessageType:(id)receiver withTypeName:(NSString*)typeName callback:(SEL)sel{
    
}
-(void)unlistenMessageType:(id)receiver withTypeName:(NSString*)typeName callback:(SEL)sel{
    
}
-(void)postMessage:(AMNotificationMessage*)msg withTypeName:(NSString*)typeName{
    
}


-(AMNotificationMessage*)createMessageWithHeader:(NSDictionary*)header withBody:(id)body{
    return nil;
}

@end
