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
}

-(id)init:(NSString*)name ip:(NSString*)ip port:(NSString*)port
{
    if (self = [super init])
    {
        _changeIndex = 2;
        
        self.name = name;
        self.ip = ip;
        self.port = port;
        self.destinations = [[NSMutableArray alloc] init];
    }
    
    return self;
}

-(void)addUserToDataSource:(NSString*)fullUserName fullGroupName:(NSString*)groupName
{
    AMETCDAddUserOperation* addUserOper = [[AMETCDAddUserOperation alloc]
                                           initWithParameter:self.ip
                                           port:self.port
                                           fullUserName:fullUserName
                                           fullGroupName:groupName
                                           ttl:Preference_MyEtCDUserTTL];
    
    
    AMETCDUserTTLOperation* userTTLOper = [[AMETCDUserTTLOperation alloc]
                                           initWithParameter:self.ip
                                           port:self.port
                                           fullUserName:fullUserName
                                           ttl:Preference_MyEtCDUserTTL];
    addUserOper.delegate = self;
    userTTLOper.delegate = self;
    
    [userTTLOper addDependency:addUserOper];
    
    [[AMMesher sharedEtcdOperQueue] addOperation:addUserOper];
    [[AMMesher sharedEtcdOperQueue] addOperation:userTTLOper];

}

-(void)watch
{
    AMETCDWatchOperation* watchOper = [[AMETCDWatchOperation alloc] init:self.ip port:self.port index:_changeIndex];
    watchOper.delegate = self;
    
    [[AMMesher sharedEtcdOperQueue] addOperation:watchOper];
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
        
        [self watch];
        return;
    }
    
}


@end
