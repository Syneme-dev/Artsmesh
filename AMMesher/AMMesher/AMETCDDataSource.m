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
{
    NSTimer* _queryTimer;
}

-(id)init:(NSString*)name ip:(NSString*)ip port:(NSString*)port
{
    if (self = [super init])
    {
        self.name = name;
        self.ip = ip;
        self.port = port;
        self.destinations = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)watch
{
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
        }
        
        _queryTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(watch) userInfo:nil repeats:NO];
    }
}


@end
