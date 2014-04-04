//
//  AMInitETCDOperation.m
//  AMMesher
//
//  Created by Wei Wang on 3/30/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMInitETCDOperation.h"
#import "AMETCDApi/AMETCD.h"

@implementation AMInitETCDOperation
{
    AMETCD* _etcdApi;
}

-(id)initWithEtcdServer:(NSString*)etcdAddr
                   port:(NSString*)cp
               delegate:(id<AMMesherOperationProtocol>)delegate
{
    if(self = [super init])
    {
        _etcdApi = [[AMETCD alloc]init];
        _etcdApi.serverIp = etcdAddr;
        _etcdApi.clientPort = [cp intValue];
        
        _isResultOK = NO;
        self.delegate = delegate;
    }
    
    return self;
}

-(void)main
{
    if(self.isCancelled){return;}
    
    NSLog(@"Initializing ETCD data...");
    
    AMETCDResult* res = [_etcdApi setDir:@"/Groups/" ttl:0 prevExist:NO];
    if(res.errCode != 0)
    {
        int retry = 0;
        for (; retry < 3; retry++)
        {
            if(self.isCancelled)
            {
                _isResultOK = NO;
                [(NSObject *)self.delegate performSelectorOnMainThread:@selector(InitETCDOperationDidFinish:) withObject:self waitUntilDone:NO];
                return;
            }
            
            res = [_etcdApi setDir:@"/Groups/" ttl:0 prevExist:NO];
            if(res.errCode == 0)
            {
                break;
            }
        }
        
        if(retry == 3)
        {
            _isResultOK = NO;
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(InitETCDOperationDidFinish:) withObject:self waitUntilDone:NO];
            return;
        }
    }
    
    _isResultOK = YES;
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(InitETCDOperationDidFinish:) withObject:self waitUntilDone:NO];
}

@end
