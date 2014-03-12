//
//  AppDelegate.m
//  UserGroupUITest
//
//  Created by 王 为 on 3/12/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AppDelegate.h"
#import <AMPluginLoader/AMPluginAppDelegateProtocol.h>
#import <AMPluginLoader/AMPluginProtocol.h>
#import "UserGroupModuleConst.h"
#import "AMMesher/AMMesher.h"
#import "AMETCDApi/AMETCD.h"
#import "AMETCDApi/AMETCDResult.h"

static NSMutableDictionary *allPlugins = nil;
#define UserGroupPluginName @"Groups"

@implementation AppDelegate
{
    AMMesher* _mesher;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    allPlugins = [self loadPlugins];
    
    _mesher = [[AMMesher alloc] init];
    [_mesher start];
    
    [self loadUserGroupPanel];
}


-(void)loadUserGroupPanel{
    //NSRect screenSize = [[NSScreen mainScreen] frame];
    
    NSRect frameRect = [self.userGroupViewPanel frame];
    id userPluginClass = allPlugins[UserGroupPluginName];
    NSViewController *userGroupViewController = [userPluginClass createMainView];
    userGroupViewController.view.frame = frameRect;
    //NSMakeRect(10.0f, screenSize.size.height - 500 - 30, 300, 500);
    [self.userGroupViewPanel addSubview:userGroupViewController.view];
    
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


@end
