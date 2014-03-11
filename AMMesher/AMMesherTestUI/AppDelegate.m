//
//  AppDelegate.m
//  AMMesherTestUI
//
//  Created by Wei Wang on 3/11/14.
//  Copyright (c) 2014 Wei Wang. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    self.mesher = [[AMMesher alloc] init];
    [self.mesher start];
}

-(void)applicationWillTerminate:(NSNotification *)notification
{
    [self.mesher stop];
}

@end
