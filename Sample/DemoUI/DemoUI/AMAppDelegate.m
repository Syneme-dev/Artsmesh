//
//  AMAppDelegate.m
//  DemoUI
//
//  Created by Sky JIA on 1/6/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMAppDelegate.h"
#import <AMPluginLoader/AMPluginProtocol.h>
#import "HelloWorldConst.h"

@implementation AMAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self loadPlugins];
    [self maxSizeWindow];
}
-(void)maxSizeWindow{
    NSRect screenSize = [[NSScreen mainScreen] frame];
    [self.window setFrame:screenSize display:YES ];
}

- (NSArray*)loadPlugins
{
	NSBundle *main = [NSBundle mainBundle];
	NSArray *allPlugins = [main pathsForResourcesOfType:@"bundle" inDirectory:@"../PlugIns"];
	NSMutableArray *availablePlugins = [NSMutableArray array];
	id plugin = nil;
	NSBundle *pluginBundle = nil;
	for (NSString *path in allPlugins) {
		pluginBundle = [NSBundle bundleWithPath:path];
		[pluginBundle load];
		Class principalClass = [pluginBundle principalClass];
		plugin = [[principalClass alloc] init];
		[availablePlugins addObject:plugin];
		plugin = nil;
		pluginBundle = nil;
        
       
	}
	return availablePlugins;
}


//TODO:delete code
-(void) onShowUserListButtonClick
{
    NSDictionary *pluginList; // read from global var.
    NSBundle *userPlugin=pluginList[HelloWorldPluginName];
    Class principalClass = [userPlugin principalClass];
    if([principalClass conformsToProtocol: @protocol(AMPlugin)]){
        NSViewController *ctl= [principalClass createMainView];
    }
    
    
}

@end
