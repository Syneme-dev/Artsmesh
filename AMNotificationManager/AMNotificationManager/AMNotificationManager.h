//
//  AMNotificationManager.h
//  AMNotificationManager
//
//  Created by Sky JIA on 12/30/13.
//  Copyright (c) 2013 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMNotificationMessage.h"

@interface AMNotificationManager : NSObject

+(AMNotificationManager *)defaultShared;

-(void)registerMessageType:(id)sender withTypeName:(NSString*)typeName;
-(void)unregisterMessageType:(id)sender withTypeName:(NSString*)typeName;
-(void)listenMessageType:(id)receiver withTypeName:(NSString*)typeName callback:(SEL)sel;
-(void)unlistenMessageType:(id)receiver withTypeName:(NSString*)typeName callback:(SEL)sel;
-(void)postMessage:(AMNotificationMessage*)msg withTypeName:(NSString*)typeName;


-(AMNotificationMessage*)createMessageWithHeader:(NSDictionary*)header withBody:(id)body;

@end
