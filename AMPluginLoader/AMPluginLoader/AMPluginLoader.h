//
//  AMPluginLoader.h
//  AMPluginLoader
//
//  Created by Sky JIA on 12/30/13.
//  Copyright (c) 2013 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMPluginLoader : NSObject

+(AMPluginLoader *)defaultShared;

-(NSArray *)getPluginPreferenceList;
-(NSArray *)getPluginList;
-(void)loadPlugin:(NSDictionary *) pluginInfo;

@end
