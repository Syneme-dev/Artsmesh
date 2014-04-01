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
#import "AMETCDPreferenceViewController.h"
#import "AMUserViewController.h"
#import "AMUserGroupViewController.h"


static NSMutableDictionary *allPlugins = nil;

@implementation AMAppDelegate
{
    AMMesher* _globalMesher;
//    AMETCD* _globalETCD;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    allPlugins = [self loadPlugins];
    [self showDefaultWindow];
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
    [self loadGroupsPanel];
    [self loadETCDPreferencePanel];
    [self loadUserPanel];
}


-(void)loadGroupsPanel{
     NSRect screenSize = [[NSScreen mainScreen] frame];
    AMPanelViewController *preViewController = [[AMPanelViewController alloc] initWithNibName:@"AMPanelView" bundle:nil];
    preViewController.view.frame = NSMakeRect(50.0f, screenSize.size.height - 720 - 60, 300.0f, 400.0f);
    [self.window.contentView addSubview:preViewController.view];
    [preViewController.titleView setStringValue:@"Groups"];
    
    AMUserGroupViewController* userGroupViewController = [[AMUserGroupViewController alloc] initWithNibName:@"AMUserGroupView" bundle:nil];
    userGroupViewController.view.frame = NSMakeRect(0,0, 300, 380);
    [preViewController.view addSubview:userGroupViewController.view];
}

-(void)loadETCDPreferencePanel{
    NSRect screenSize = [[NSScreen mainScreen] frame];
    AMPanelViewController *preViewController = [[AMPanelViewController alloc] initWithNibName:@"AMPanelView" bundle:nil];
    
    [self.window.contentView addSubview:preViewController.view];
    [preViewController.titleView setStringValue:@"Preference"];
    preViewController.view.frame = NSMakeRect(410.0f, screenSize.size.height - 720 - 60, 600.0f, 720.0f);

    
    
    AMETCDPreferenceViewController *etcdPreference = [[AMETCDPreferenceViewController alloc] initWithNibName:@"AMETCDPreferenceView" bundle:nil];
    etcdPreference.view.frame = NSMakeRect(0,360, 600, 300);
    [preViewController.view addSubview:etcdPreference.view];
}

-(void)loadUserPanel
{
    NSRect screenSize = [[NSScreen mainScreen] frame];
    AMPanelViewController *userPanelViewController = [[AMPanelViewController alloc] initWithNibName:@"AMPanelView" bundle:nil];
    userPanelViewController.view.frame = NSMakeRect(50.0f, screenSize.size.height - 300 - 60, 300.0f, 300.0f);
    [self.window.contentView addSubview:userPanelViewController.view];
    [userPanelViewController.titleView setStringValue:@"User"];
    AMUserViewController *userViewController = [[AMUserViewController alloc] initWithNibName:@"AMUserView" bundle:nil];
    userViewController.view.frame = NSMakeRect(0,0, 400, 300);
    [userPanelViewController.view addSubview:userViewController.view];
    
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
