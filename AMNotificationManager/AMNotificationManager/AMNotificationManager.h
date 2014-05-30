//
//  AMNotificationManager.h
//  AMNotificationManager
//
//  Created by Sky JIA on 12/30/13.
//  Copyright (c) 2013 Artsmesh. All rights reserved.
//

#define AMN_NOTIFICATION_MANAGER [AMNotificationManager defaultShared]
#import <Foundation/Foundation.h>
#import "AMNotificationMessage.h"

static NSString* const AMN_MESHER_STARTED = @"AMN_MESHER_STARTED";
static NSString* const AM_USERGROUPS_CHANGED = @"AM_USERGROUPS_CHANGED";
static NSString* const AM_MESHER_ONLINE= @"AM_MESHER_ONLINE";

@interface AMNotificationManager : NSObject

+(AMNotificationManager *)defaultShared;
-(void)listenMessageType:(id)receiver withTypeName:(NSString*)typeName callback:(SEL)sel;
-(void)unlistenMessageType:(id)receiver;
-(AMNotificationMessage*)createMessageWithHeader:(NSDictionary*)header withBody:(id)body;
//-(void)postMessage:(AMNotificationMessage*)msg withTypeName:(NSString*)typeName source:(id)sender;
-(void)postMessage:(NSDictionary*)parameters withTypeName:(NSString*)typeName source:(id)sender;

@end
