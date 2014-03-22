//
//  AMETCDSycnService.m
//  AMMesher
//
//  Created by Wei Wang on 3/22/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDSyncService.h"
#import "AMETCDApi/AMETCD.h"

@implementation AMETCDSyncService
{
    int _state;
    AMETCD* _etcd;
}

-(id)init
{
    if (self = [super init]) {
        _state = 19;
        
        _etcd = [[AMETCD alloc]init];
    }
    
    return self;
}

-(void)startSync:(NSString*)leaderAddr
{
    //
}

-(void)stopSync
{
    
}

-(void)setTestIntVal:(int)s
{
    _state = s;
}

-(void)getTestIntVal:(void(^)(int))reply
{
    reply(_state);
}

@end
