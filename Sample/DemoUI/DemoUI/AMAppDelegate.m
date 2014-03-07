//
//  AMAppDelegate.m
//  DemoUI
//
//  Created by Sky JIA on 1/6/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//


#import <AMPluginLoader/AMPluginAppDelegateProtocol.h>
#import "AMAppDelegate.h"
#import <AMPluginLoader/AMPluginProtocol.h>
#import <AMNotificationManager/AMNotificationManager.h>
#import <AMPreferenceManager/AMPreferenceManager.h>
#import "HelloWorldConst.h"
#import "AMPanelViewController.h"
#import "UserGroupModuleConst.h"

static NSMutableDictionary *allPlugins = nil;

@implementation AMAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    allPlugins = [self loadPlugins];
    [self showDefaultWindow];
    [self showTestPanel];   //TODO:to be deleted as test code.
    BOOL isPreferenceCompleted = [self checkRequirementPreferenceCompleted];
    if (!isPreferenceCompleted) {
        [self showPreferencePanel];
    }
    [self startMesher];
    [self connectMesher];
    [self writePluginDataToMesher];
}

- (void)connectMesher {
    //TODO:
}

- (void)startMesher {
    //TODO:
}

- (void)showPreferencePanel {
    //TODO:
}

- (BOOL)checkRequirementPreferenceCompleted {
    //TODO:
    return NO;
}

- (void)writePluginDataToMesher {
    //TODO:

}

- (void)showDefaultWindow {
    NSRect screenSize = [[NSScreen mainScreen] frame];
    [self.window setFrame:screenSize display:YES ];

    id userPluginClass = allPlugins[UserGroupPluginName];

    NSViewController *userGroupViewController = [userPluginClass createMainView];
    userGroupViewController.view.frame = NSMakeRect(10.0f, screenSize.size.height - 300 - 30, 300, 300);
    [self.window.contentView addSubview:userGroupViewController.view];
}

- (void)showTestPanel {
    NSRect screenSize = [[NSScreen mainScreen] frame];
    AMPanelViewController *panelViewController = [[AMPanelViewController alloc] initWithNibName:@"AMPanelView" bundle:nil];
    panelViewController.view.frame = NSMakeRect(410.0f, screenSize.size.height - 300 - 30, 300, 300);
    [self.window.contentView addSubview:panelViewController.view];
}

- (NSMutableDictionary *)loadPlugins {
    NSBundle *main = [NSBundle mainBundle];
    NSArray *allPlugins = [main pathsForResourcesOfType:@"bundle" inDirectory:@"../PlugIns"];
    NSMutableDictionary *availablePlugins = [NSMutableDictionary dictionaryWithCapacity:10];
    id plugin = nil;
    NSString *pluginName = nil;
    NSBundle *pluginBundle = nil;
    for (NSString *path in allPlugins) {
        pluginBundle = [NSBundle bundleWithPath:path];
        [pluginBundle load];
        Class principalClass = [pluginBundle principalClass];
        pluginName = [[principalClass alloc] displayName];
        plugin = [[principalClass alloc] init:self bundle:pluginBundle];
        [availablePlugins setObject:plugin forKey:pluginName];
        pluginName = nil;
        plugin = nil;
        pluginBundle = nil;
    }
    return availablePlugins;
}

- (AMNotificationManager *)sharedNotificationManager {
    return [AMNotificationManager defaultShared];
}

- (AMPreferenceManager *)sharedPreferenceManger {
    return [AMPreferenceManager defaultShared];
}


@end
