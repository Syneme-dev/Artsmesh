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
    
    NSString* rootDir = @"/Users/";
    
    int actIndex;
    self.operationResult= [self.etcdApi watchDir:rootDir fromIndex:self.expectedIndex acturalIndex:&actIndex timeout:5];
    if(self.operationResult.errCode == 0)
    {
        self.isResultOK = YES;
        self.currentIndex = actIndex;
    }
    else
    {
        self.isResultOK = NO;
    }

    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AMETCDOperationDidFinished:) withObject:self waitUntilDone:NO];
}




@end
