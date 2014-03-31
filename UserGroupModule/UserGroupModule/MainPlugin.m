//
//  MainPlugin.m
//  UserGroupModule
//
//  Created by xujian on 3/3/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "MainPlugin.h"
#import "MainViewController.h"

static NSBundle *defaultBundle = nil;

@implementation MainPlugin
{
    MainViewController* _mainViewController;
}


# pragma mark
# pragma mark General



- (NSString *)displayName {
    return @"Groups";
}

-(BOOL)canQuit
{
    if(_mainViewController)
    {
        [_mainViewController StopEverything];
    }
    
    return YES;
}

- (id)init:(id <AMPluginAppDelegate>)amAppDelegateProtocol bundle:(NSBundle *)bundle {
    defaultBundle = bundle;
    self = [super init];
    return self;
}


- (void)registerAllMessageListeners {

}

- (NSViewController *)createMainView {
    _mainViewController = [[MainViewController alloc] initWithNibName:@"MainView" bundle:defaultBundle];
    return _mainViewController;
}


# pragma mark
# pragma mark Notification

- (void)registerAllMessageTypes {
    //TODO:
}

# pragma mark
# pragma mark Preference

- (void)loadPreference {
    //TODO:
}

- (void)savePreference:(NSDictionary *)pref {
    //TODO:
}

- (void)registerPreference {
    //TODO:
}


@end
