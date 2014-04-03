//
//  AMUserTTLOperator.m
//  AMMesher
//
//  Created by 王 为 on 3/31/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMUserTTLOperator.h"
#import "AMETCDApi/AMETCD.h"

@implementation AMUserTTLOperator
{
    AMETCD* _etcdApi;
    NSString* _username;
    NSString* _groupname;
    int _ttltime;
}

-(id)initWithParameter:(NSString*)hostAddr
            serverPort:(NSString*)cp
              username:(NSString*)username
             groupname:(NSString*)groupname
               ttltime:(int)ttltime
              delegate:(id<AMMesherOperationProtocol>)delegate
{
    if (self = [super init])
    {
        _etcdApi = [[AMETCD alloc]init];
        _etcdApi.serverIp = hostAddr;
        _etcdApi.clientPort = [cp intValue];
        
        _username = username;
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
    
    NSString* userDir = [NSString stringWithFormat:@"/Groups/%@/Users/%@/", _groupname, _username];

    for (; retry < 3; retry++)
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
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(UserTTLOperatorDidFinish:) withObject:self waitUntilDone:NO];
        return;
    }
    
    _isResultOK = YES;
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(UserTTLOperatorDidFinish:) withObject:self waitUntilDone:NO];
}

@end
