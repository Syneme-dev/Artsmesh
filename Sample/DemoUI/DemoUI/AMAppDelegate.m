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
#import "AMOscGroups/AMOSCGroups.h"


static NSMutableDictionary *allPlugins = nil;

@interface AMAppDelegate () <AMPluginAppDelegate>
@end


@implementation AMAppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    BOOL bRet = AMLogInitialize();
    if (!bRet) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Init Log Module Error" defaultButton:@"Ok" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Can not open log file!"];
        [alert runModal];
        
        return;
    }
    
    AMLog(kAMInfoLog, @"Main", @"Artsmesh is Starting...");
    allPlugins = [self loadPlugins];
    
    [[AMPreferenceManager shareInstance] initPreference];
    AMLog(kAMInfoLog, @"Main", @"Preference is initialized.");
    
    [[AMStatusNet shareInstance] loadGroups];
    [self.mainWindowController showDefaultWindow];
    AMLog(kAMInfoLog, @"Main", @"Default Panels are initialized.");
    
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
    [[AMOSCGroups sharedInstance] stopOSCGroupClient];
    [[AMOSCGroups sharedInstance] stopOSCGroupServer];
    
    
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
