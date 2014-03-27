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
#import "AMMesher/AMMesher.h"
//#import "AMETCDApi/AMETCD.h"
//#import "AMETCDApi/AMETCDResult.h"

static NSMutableDictionary *allPlugins = nil;

@implementation AMAppDelegate
{
    AMMesher* _globalMesher;
//    AMETCD* _globalETCD;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    allPlugins = [self loadPlugins];
    [self showDefaultWindow];
   // [self showTestPanel];   //TODO:to be deleted as test code.
    BOOL isPreferenceCompleted = [self checkRequirementPreferenceCompleted];
    if (!isPreferenceCompleted) {
        [self showPreferencePanel];
    }
    [self startMesher];
    [self connectMesher];
    [self writePluginDataToMesher];
}

-(void)applicationWillTerminate:(NSNotification *)notification
{
    id userPluginClass = allPlugins[UserGroupPluginName];
    [userPluginClass canQuit];
    
    [_globalMesher stopLocalMesher];
    
    
}

- (void)connectMesher {
    //TODO:
}

- (void)startMesher {
    //TODO:
    
    _globalMesher = [[AMMesher alloc] init];
    [_globalMesher startLoalMesher];
   
//    [_globalMesher addObserver:self
//                    forKeyPath:@"mesherName"
//                       options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
//                       context:Nil];
    
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
    [self loadUserGroupPanel];
    
    
}

-(void)loadUserGroupPanel{
    NSRect screenSize = [[NSScreen mainScreen] frame];
    id userPluginClass = allPlugins[UserGroupPluginName];
    NSViewController *userGroupViewController = [userPluginClass createMainView];
    userGroupViewController.view.frame = NSMakeRect(10.0f, screenSize.size.height - 500 - 30, 365, 430);
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


#pragma mark -
#pragma mark KVO
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    if([keyPath isEqualToString:@"mesherName"]){
        NSLog(@"Old Mesher is: %@\n", [change objectForKey:NSKeyValueChangeOldKey]);
        NSLog(@"New Mesher is: %@\n", [change objectForKey:NSKeyValueChangeNewKey]);
        
        self.mesherName.stringValue = [change objectForKey:NSKeyValueChangeNewKey];
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}


@end
