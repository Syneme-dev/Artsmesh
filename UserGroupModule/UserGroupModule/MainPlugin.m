//
//  MainPlugin.m
//  UserGroupModule
//
//  Created by xujian on 3/3/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "MainPlugin.h"

@implementation MainPlugin


# pragma mark
# pragma mark General

-(id)init
{
    NSLog(@"UserGroupPlugin is loaded.");
    return self;
}

-(NSString *) displayName
{
    return @"User Group";
}

# pragma mark
# pragma mark Notification

-(NSString *) registerAllMessageTypes
{
    //TODO:
    return @"??";
}

# pragma mark
# pragma mark Preference

-(void) loadPreference
{
    //TODO:
}
-(void) savePreference:(NSDictionary *)pref
{
    //TODO:
}
-(void) registerPreference
{
    //TODO:
}



@end
