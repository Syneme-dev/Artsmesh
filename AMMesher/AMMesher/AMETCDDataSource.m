//
//  AMETCDDataSource.m
//  AMMesher
//
//  Created by Wei Wang on 4/7/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDDestination.h"
#import "AMMesher.h"
#import "AMETCDOperationHeader.h"


@implementation AMETCDDataSource

-(id)init:(NSString*)name ip:(NSString*)ip port:(NSString*)port
{
    if (self = [super init])
    {
        _changeIndex = 2;
        _watching = NO;
        
        self.name = name;
        self.ip = ip;
        self.port = port;
        self.destinations = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)watch
{
    _watching = YES;
    
    AMETCDQueryOperation* queryOper = [[AMETCDQueryOperation alloc] init:self.ip port:self.port];
    queryOper.delegate = self;
    [[AMMesher sharedEtcdOperQueue] addOperation:queryOper];
}

-(void)stopWatch
{
    [[AMMesher sharedEtcdOperQueue] cancelAllOperations];
    _watching = NO;
}

-(void)addDestination:(AMETCDDestination*)dest
{
    @synchronized(self)
    {
        [self.destinations addObject:dest];
    }
}

-(void)removeDestination:(AMETCDDestination *)dest
{
    @synchronized(self)
    {
        [self.destinations removeObject:dest];
    }
}


- (void)AMETCDOperationDidFinished:(AMETCDOperation *)oper
{
    if(![oper isKindOfClass:[AMETCDOperation class]])
    {
        return;
    }
    
    if ([oper isKindOfClass:[AMETCDQueryOperation class]] && oper.isResultOK == YES)
    {
        @synchronized(self)
        {
            for(AMETCDDestination* dest in self.destinations)
            {
                [dest handleQueryEtcdFinished:oper.operationResult source:self];
            }
            
            if (oper.operationResult.node != nil)
            {
                int modifyIndex = oper.operationResult.node.modifiedIndex;
                int createIndex = oper.operationResult.node.createdIndex;
                self.changeIndex = (modifyIndex > createIndex) ? modifyIndex : createIndex;
                
                if (oper.operationResult.node.nodes != nil)
                {
                    for (AMETCDNode* userNode in oper.operationResult.node.nodes)
                    {
                        self.changeIndex = self.changeIndex > userNode.modifiedIndex ? self.changeIndex: userNode.modifiedIndex;
                        self.changeIndex = self.changeIndex > userNode.createdIndex ? self.changeIndex: userNode.createdIndex;
                    }
                }
            }
        }
        
        AMETCDWatchOperation* watchOper = [[AMETCDWatchOperation alloc] init:self.ip port:self.port path: @"/Users/" index:self.changeIndex];
        watchOper.delegate = self;
        [[AMMesher sharedEtcdOperQueue] addOperation:watchOper];


        return;
    }
    
    if ([oper isKindOfClass:[AMETCDWatchOperation class]])
    {
        AMETCDWatchOperation* watchOper = (AMETCDWatchOperation*)oper;
        
        if (watchOper.isResultOK == YES)
        {
            self.changeIndex =  self.changeIndex > (watchOper.currentIndex+1) ? (self.changeIndex) : (watchOper.currentIndex+1);
            
            @synchronized(self)
            {
                for(AMETCDDestination* dest in self.destinations)
                {
                    [dest handleWatchEtcdFinished:oper.operationResult source:self];
                }
            }
        }
        
        if (self.watching)
        {
            AMETCDWatchOperation* watchOper = [[AMETCDWatchOperation alloc] init:self.ip port:self.port path: @"/Users/" index:self.changeIndex];
            watchOper.delegate = self;
            [[AMMesher sharedEtcdOperQueue] addOperation:watchOper];
        }
        
        return;
    }
    
}


@end
