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
    BOOL _isWatchingLeader;
}

-(id)init
{
    if (self = [super init]) {
        _state = 19;
        
        _isWatchingLeader = NO;
        
        _etcd = [[AMETCD alloc]init];
    }
    
    return self;
}

-(void)startSync:(NSString*)ip port:(int)p
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        int watchInedex = 2;
        int actualIndex = 0;
        
        if(_etcd == nil)
        {
            _etcd = [[AMETCD alloc]init];
        }
        
        _etcd.serverIp = ip;
        _etcd.serverPort = p;
        
        _isWatchingLeader = YES;
        
        AMETCDResult* res;
        
        while (1)
        {
            //the fisrt watch is get the actually index;
            res = [_etcd watchDir:@"/" fromIndex:watchInedex acturalIndex:&actualIndex timeout:5];
            if(res.errCode == 0)
            {
                watchInedex = actualIndex;
                res = [_etcd listDir:@"/" recursive:YES];
                //save all the thing to dir;
                
                break;
            }
        }
        
        watchInedex++;
        while(_isWatchingLeader)
        {
            //this watch is for getting the etcd data;
            res = [_etcd watchDir:@"/" fromIndex:watchInedex acturalIndex:&actualIndex timeout:5];
            if(res.errCode == 0)
            {
                //save the change to dir
            }
        }

    });
}

-(void)stopSync
{
    _isWatchingLeader = NO;
    
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
