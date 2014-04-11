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
#import "AMMesherPreference.h"


@implementation AMETCDDataSource
{
    int _changeIndex;
    BOOL _watching;
}

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
    AMETCDWatchOperation* watchOper = [[AMETCDWatchOperation alloc] init:self.ip port:self.port path: @"/Users/" index:_changeIndex];
    watchOper.delegate = self;
    
    [[AMMesher sharedEtcdOperQueue] addOperation:watchOper];
    _watching = YES;
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
    
    AMETCDQueryOperation* queryOper = [[AMETCDQueryOperation alloc] init:self.ip port:self.port];
    queryOper.delegate = self;
    
    [[AMMesher sharedEtcdOperQueue] addOperation:queryOper];
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
        }
        
        return;
    }
    
    if ([oper isKindOfClass:[AMETCDWatchOperation class]])
    {
        AMETCDWatchOperation* watchOper = (AMETCDWatchOperation*)oper;
        
        if (watchOper.isResultOK == YES)
        {
            _changeIndex =  watchOper.currentIndex + 1;
            
            @synchronized(self)
            {
                for(AMETCDDestination* dest in self.destinations)
                {
                    [dest handleWatchEtcdFinished:oper.operationResult source:self];
                }
            }
        }
        
        if (_watching)
        {
            [self watch];
        }
        
        return;
    }
    
}


@end
