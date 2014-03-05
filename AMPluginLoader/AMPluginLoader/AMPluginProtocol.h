//
//  AMPlugin.h
//  AMPluginLoader
//
//  Created by Sky JIA on 1/7/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AMPlugin <NSObject>


# pragma mark
# pragma mark General

-(NSString *) displayName;

# pragma mark
# pragma mark Notification

-(NSString *) registerAllMessageTypes;

# pragma mark
# pragma mark Preference

-(void) loadPreference;
-(void) savePreference:(NSDictionary *)pref;
-(void) registerPreference;

-(NSViewController *)createMainView;

@end
