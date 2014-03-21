//
//  main.m
//  AMLocalMesherService
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#include <xpc/xpc.h>
#include <Foundation/Foundation.h>
#import "AMLocalMesherDelegate.h"

int main(int argc, const char *argv[])
{
    NSXPCListener* listener = [NSXPCListener serviceListener];
    AMLocalMesherDelegate* delegate = [[AMLocalMesherDelegate alloc] init];
    listener.delegate = delegate;
    [listener resume];
    
	exit(EXIT_FAILURE);
}
