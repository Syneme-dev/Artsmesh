//
//  AMAppDelegate.m
//  DemoUI
//
//  Created by Sky JIA on 1/6/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//


#import "AMAppDelegate.h"
#import <AMPreferenceManager/AMPreferenceManager.h>
#import "AMMesher/AMMesher.h"
#import "AMStatusNet/AMStatusNet.h"
#import "AMAudio/AMAudio.h"
#import "AMLogger/AMLogger.h"
#import "AMOscGroups/AMOSCGroups.h"


@implementation AMAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"WebKitDeveloperExtras"]];
     [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"IncludeDebugMenu"]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSAssert(AMLogInitialize(), @"Initialize Log Error!");
    
    AMLog(kAMInfoLog, @"Main", @"Artsmesh is Starting...");
    
    [self loadPreference];
    [self loadPanels];
    
    //TODO:the following two should not be here too
    [self loadArchieveGroups];
    [self loadLiveGroups];
}


-(void)loadPreference
{
    [[AMPreferenceManager shareInstance] initPreference];
    AMLog(kAMInfoLog, @"Main", @"Preference is initialized.");
}


-(void)loadPanels
{
    [self.mainWindowController showDefaultWindow];
    AMLog(kAMInfoLog, @"Main", @"Panels loaded!");
}


-(void)loadArchieveGroups
{
    [[AMStatusNet shareInstance] loadGroups];
    AMLog(kAMInfoLog, @"Main", @"Loading archieve groups.");
}


-(void)loadLiveGroups
{
    [[AMMesher sharedAMMesher] startMesher];
    AMLog(kAMInfoLog, @"Main", @"Loading live groups.");
}


- (void)applicationWillTerminate:(NSNotification *)notification {

    //TODO: Here we should not use osc or audio directly, we should send quit notifications, then
    //the panel itself will release the resource
    [[AMMesher sharedAMMesher] stopMesher];
    [[AMAudio sharedInstance] releaseResources];
    [[AMOSCGroups sharedInstance] stopOSCGroupClient];
    [[AMOSCGroups sharedInstance] stopOSCGroupServer];
    
    AMLogClose();
}

@end
