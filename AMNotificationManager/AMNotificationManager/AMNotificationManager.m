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

+ (void)initialize
{
    if (self == [AMNotificationManager class])
    {
        sharedManager = [[self alloc] init];
    }
}


-(void)listenMessageType:(id)receiver withTypeName:(NSString*)typeName callback:(SEL)sel
{
    [[NSNotificationCenter defaultCenter] addObserver:receiver selector:sel name:typeName object:nil];
}

-(void)unlistenMessageType:(id)receiver
{
    [[NSNotificationCenter defaultCenter] removeObserver:receiver];
}

-(void)postMessage:(NSDictionary*)parameters withTypeName:(NSString*)typeName source:(id)sender;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // do work here
        [[NSNotificationCenter defaultCenter] postNotificationName:typeName object:sender userInfo:parameters];
    });
}


-(AMNotificationMessage*)createMessageWithHeader:(NSDictionary*)header withBody:(id)body
{
    return nil;
}

@end
