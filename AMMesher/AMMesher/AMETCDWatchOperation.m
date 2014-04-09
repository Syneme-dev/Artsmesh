//
//  AMETCDWatchOperation.m
//  AMMesher
//
//  Created by Wei Wang on 4/7/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDWatchOperation.h"
#import "AMETCDOperationDelegate.h"
#import "AMETCDApi/AMETCD.h"

@implementation AMETCDWatchOperation

-(id)init:(NSString*)ip
     port:(NSString*)port
    index:(int)index
{
    if(self = [super init:ip port:port])
    {
        self.operationType = @"watch";
        self.expectedIndex = index;
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
    
    NSLog(@"watch etcd...");
    
    int retry = 0;
    
    NSString* rootDir = @"/Groups/";
    
    for (retry =0; retry < 3; retry++)
    {
        if(self.isCancelled)
        {
            self.isResultOK = NO;
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AMETCDOperationDidFinished:) withObject:self waitUntilDone:NO];
            return;
        }
        
        int actIndex;
        self.operationResult= [self.etcdApi watchDir:rootDir fromIndex:self.expectedIndex acturalIndex:&actIndex timeout:1];
        if(self.operationResult.errCode == 0)
        {
            self.currentIndex = actIndex;
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
