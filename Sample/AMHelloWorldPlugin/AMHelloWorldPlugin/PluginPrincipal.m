//
//  PluginPrincipal.m
//  AMHelloWorldPlugin
//
//  Created by Sky JIA on 1/6/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <AMNotificationManager/AMNotificationManager.h>
#import <AMPluginLoader/AMPluginAppDelegateProtocol.h>
#import "PluginPrincipal.h"
#import "HelloWorldViewController.h"


@implementation PluginPrincipal

# pragma mark
# pragma mark General


-(NSString *) displayName
{
    return @"HelloWorldPlugin";
}

- (id)init:(id <AMPluginAppDelegate>)amAppDelegateProtocol bundle:(NSBundle *)bundle {
    NSLog(@"HelloWorldPlugin is loaded.");
    [self registerAllMessageListeners];
    [self registerPreference];
    return self;
}


# pragma mark
# pragma mark Notification

-(void) registerAllMessageListeners
{
    [AMN_NOTIFICATION_MANAGER listenMessageType:self withTypeName:AMN_MESHER_STARTED callback:@selector(onFunctionOneInvoked)];
}

# pragma mark
# pragma mark Preference

//invoke when show to UI.
-(NSDictionary *) loadPreference
{
    //Note:option implement. If bind to UI ,you can have no code here.
    return nil;
}
//invoke when editing on preference panel.
-(void) savePreference:(NSDictionary *)pref
{
    //Note:option implement. If bind to UI ,you can have no code here.
}
//when application launch ,register for default value.
-(void) registerPreference
{
    //TODO:
}



//Click an button to invoke this method.
-(void) FunctionOneInvoke
{

    AMNotificationMessage *message=[AMN_NOTIFICATION_MANAGER createMessageWithHeader:nil withBody:nil];
//    [AMN_NOTIFICATION_MANAGER postMessage:message withTypeName:AMN_MESHER_STARTED sender:self];
}

-(void) onFunctionOneInvoked{
    //Do what you want when received message;

}
-(NSViewController *) createMainView{
    HelloWorldViewController *viewController=[[HelloWorldViewController alloc] initWithNibName:@"HelloWorldView" bundle:nil];
    return viewController;
}

@end
