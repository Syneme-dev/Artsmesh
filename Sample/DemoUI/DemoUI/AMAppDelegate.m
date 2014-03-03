//
//  AMAppDelegate.m
//  DemoUI
//
//  Created by Sky JIA on 1/6/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMAppDelegate.h"

@implementation AMAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self loadPlugins];
    // Insert code here to initialize your application
}

- (NSArray*)loadPlugins
{
	NSBundle *main = [NSBundle mainBundle];
	NSArray *allPlugins = [main pathsForResourcesOfType:@"bundle" inDirectory:@"../PlugIns"];
	NSMutableArray *availablePlugins = [NSMutableArray array];
	id plugin = nil;
    NSLog(@"xx");
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

@end
