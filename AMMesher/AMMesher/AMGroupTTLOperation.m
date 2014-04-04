//
//  AMGroupTTLOperation.m
//  AMMesher
//
//  Created by 王 为 on 4/3/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMGroupTTLOperation.h"
#import "AMETCDApi/AMETCD.h"

@implementation AMGroupTTLOperation
{
    AMETCD* _etcdApi;
    NSString* _groupname;
    int _ttltime;
}

-(id)initWithParameter:(NSString*)hostAddr
            serverPort:(NSString*)cp
             groupname:(NSString*)groupname
               ttltime:(int)ttltime
              delegate:(id<AMMesherOperationProtocol>)delegate
{
    if (self = [super init])
    {
        _etcdApi = [[AMETCD alloc]init];
        _etcdApi.serverIp = hostAddr;
        _etcdApi.clientPort = [cp intValue];
        
        _groupname = groupname;
        _ttltime = ttltime;
        _isResultOK = NO;
        
        self.delegate = delegate;
        
    }
    return self;
}

-(void)main
{
    if (self.isCancelled){return;}
    
    NSLog(@"Updating TTL information...");
    
    int retry = 0;
    
    NSString* userDir = [NSString stringWithFormat:@"/Groups/%@/", _groupname];
    
    for (retry = 0; retry < 3; retry++)
    {
        if(self.isCancelled){return;}
        
        AMETCDResult* res = [_etcdApi setDir:userDir ttl:_ttltime prevExist:YES];
        if(res != nil && res.errCode == 0)
        {
            retry = 0;
            break;
        }
    }
    
    if (retry == 3)
    {
        _isResultOK = NO;
        return;
    }
    
    _isResultOK = YES;
}


@end
