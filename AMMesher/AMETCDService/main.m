//
//  main.m
//  AMETCDService
//
//  Created by Wei Wang on 3/22/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#include <xpc/xpc.h>
#include <Foundation/Foundation.h>
#import "AMETCDDelegate.h"

int main(int argc, const char *argv[])
{
    NSXPCListener* listener = [NSXPCListener serviceListener];
    AMETCDDelegate* delegate = [[AMETCDDelegate alloc] init];
    listener.delegate = delegate;
    [listener resume];
    
	exit(EXIT_FAILURE);
}
