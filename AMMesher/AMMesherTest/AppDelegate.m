//
//  AppDelegate.m
//  AMMesherTest
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AppDelegate.h"
#import "AMMesher.h"

@implementation AppDelegate
{
    AMMesher* _mesher;
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    _mesher = [[AMMesher alloc]init];
    
    [_mesher kickoffMesherProcess];
}

-(void)applicationWillTerminate:(NSNotification *)notification
{
    [_mesher stopMesher];
}

@end
