//
//  AMKillETCDOperation.m
//  AMMesher
//
//  Created by 王 为 on 4/1/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMKillETCDOperation.h"

@implementation AMKillETCDOperation

-(void)main
{
    if (self.isCancelled) { return; }
    
    NSLog(@"Killing ETCD...");
    
    [NSTask launchedTaskWithLaunchPath:@"/usr/bin/killall"
                             arguments:[NSArray arrayWithObjects:@"-c", @"etcd", nil]];
    usleep(1000*500);
}

@end
