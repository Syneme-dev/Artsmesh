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
#import "UserGroupModuleConst.h"
#import "AMMesher/AMMesher.h"
#import "AMStatusNet/AMStatusNet.h"
#import "AMAudio/AMAudio.h"
#import "AMLogger/AMLogger.h"


static NSMutableDictionary *allPlugins = nil;

@interface AMAppDelegate () <AMPluginAppDelegate>
@end


// global uncaught exception handler
void uncaughtExceptionHandler(NSException *exception) {
    AMLog(kAMErrorLog, @"Uncaught Exception", @"an uncaught exception happened: %@",exception.description);
}

@implementation AMAppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    AMLogInitialize();
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    allPlugins = [self loadPlugins];
    [[AMPreferenceManager shareInstance] initPreference];
    [[AMStatusNet shareInstance] loadGroups];
    [self.mainWindowController showDefaultWindow];
    BOOL isPreferenceCompleted = [self checkRequirementPreferenceCompleted];
    if (!isPreferenceCompleted) {
        [self showPreferencePanel];
    }
    [self startMesher];
    [self writePluginDataToMesher];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    id userPluginClass = allPlugins[UserGroupPluginName];
    [userPluginClass canQuit];
    [[AMMesher sharedAMMesher] stopMesher];
    
    [[AMAudio sharedInstance] releaseResources];
    
    AMLogClose();
}

- (void)connectMesher {
    //TODO:
}

- (void)startMesher {
    //TODO:
    [[AMMesher sharedAMMesher] startMesher];
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
    return [AMPreferenceManager shareInstance];
}



@end
