//
//  PluginPrincipal.m
//  AMHelloWorldPlugin
//
//  Created by Sky JIA on 1/6/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "PluginPrincipal.h"

@implementation PluginPrincipal

# pragma mark
# pragma mark General

-(id)init
{
    NSLog(@"HelloWorldPlugin is loaded.");
    return self;
}

-(NSString *) displayName
{
    return @"HelloWorldPlugin";
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
