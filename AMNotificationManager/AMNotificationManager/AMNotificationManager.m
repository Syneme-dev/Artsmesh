//
//  AMNotificationManager.m
//  AMNotificationManager
//
//  Created by Sky JIA on 12/30/13.
//  Copyright (c) 2013 Artsmesh. All rights reserved.
//

#import <AMPreferenceManager/AMPreferenceManager.h>
#import "AMNotificationManager.h"

@implementation AMNotificationManager




+(AMNotificationManager *)defaultShared{
    return nil;
}

-(id) init{
    return nil;
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
