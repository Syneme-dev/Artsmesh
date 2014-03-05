//
//  PluginPrincipal.m
//  AMHelloWorldPlugin
//
//  Created by Sky JIA on 1/6/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <AMNotificationManager/AMNotificationManager.h>
#import "PluginPrincipal.h"


@implementation PluginPrincipal

# pragma mark
# pragma mark General

-(id)init
{
    NSLog(@"HelloWorldPlugin is loaded.");
    [self registerAllMessageTypes];
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
    [AMN_NOTIFICATION_MANAGER registerMessageType:self withTypeName:AMN_MESHER_STARTED];
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

-(void)LinstenFunctionOne{

    [AMN_NOTIFICATION_MANAGER listenMessageType:self withTypeName:AMN_MESHER_STARTED callback:@selector(onFunctionOneInvoked)];
}

-(void) FunctionOneInvoke
{

    AMNotificationMessage *message=[AMN_NOTIFICATION_MANAGER createMessageWithHeader:nil withBody:nil];
    [AMN_NOTIFICATION_MANAGER postMessage:message withTypeName:AMN_MESHER_STARTED];
}

-(void) onFunctionOneInvoked{
    //Do what you want when received message;

}

@end
