//
//  AMETCDQueryOperation.m
//  AMMesher
//
//  Created by Wei Wang on 4/7/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDOperation.h"
#import "AMETCDQueryOperation.h"
#import "AMETCDApi/AMETCD.h"

@implementation AMETCDQueryOperation


-(id)init:(NSString*)ip
     port:(NSString*)port
{
    if(self = [super init:ip port:port])
    {
        self.operationType = @"query";
    }
    
    return self;
}

-(void)main
{
    if (self.isCancelled)
    {
        self.isResultOK = NO;
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AMETCDOperationDidFinished:) withObject:self waitUntilDone:NO];
        return;
    }
    
     NSLog(@"Server:%@ Querying...", self.etcdApi.serverIp);
    
    int retry = 0;
    
    NSString* rootDir = @"/Users/";
    
    for (retry =0; retry < 3; retry++)
    {
        if(self.isCancelled)
        {
            self.isResultOK = NO;
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AMETCDOperationDidFinished:) withObject:self waitUntilDone:NO];
            return;
        }
        
        self.operationResult= [self.etcdApi listDir:rootDir recursive:YES];
        if(self.operationResult.errCode == 0)
        {
            self.isResultOK = YES;
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AMETCDOperationDidFinished:) withObject:self waitUntilDone:NO];
            return;
        }
    }
    
    if (retry == 3)
    {
        self.isResultOK = NO;
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AMETCDOperationDidFinished:) withObject:self waitUntilDone:NO];
        return;
    }
}

@end
