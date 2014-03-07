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



-(NSString *) displayName
{
    return @"User Group";
}

- (void)registerAllMessageListeners {

}

- (NSViewController *)createMainView {
    return nil;
}


# pragma mark
# pragma mark Notification

-(void) registerAllMessageTypes
{
    //TODO:
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
