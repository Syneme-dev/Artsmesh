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
    AMUserGroupViewController* _userGroupViewController;

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
    
    [[AMMesher sharedAMMesher] stopLocalMesher];
}

- (void)connectMesher {
    //TODO:
}

- (void)startMesher {
    //TODO:
    
    [[AMMesher sharedAMMesher] startLoalMesher];
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
    //Note:code make the window max size.
    [self.window setFrame:screenSize display:YES ];
    float appleMenuBarHeight=20.0f;
    [self.window setFrameOrigin:NSMakePoint(0.0f, screenSize.size.height-appleMenuBarHeight)];
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
    
    _userGroupViewController = [[AMUserGroupViewController alloc] initWithNibName:@"AMUserGroupView" bundle:nil];
    _userGroupViewController.view.frame = NSMakeRect(0,0, 300, 380);
    [preViewController.view addSubview:_userGroupViewController.view];
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

- (IBAction)mesh:(id)sender {
    
    NSLog(@"start mesh");
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
