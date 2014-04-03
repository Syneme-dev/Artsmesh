//
//  AMDeleteUserOperation.m
//  AMMesher
//
//  Created by Wei Wang on 3/30/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMDeleteUserOperation.h"
#import "AMETCDApi/AMETCD.h"

@implementation AMDeleteUserOperation
{
    AMETCD* _etcdApi;
    NSString* _username;
    NSString* _groupname;
}

-(id)initWithParameter:(NSString*)hostAddr
            serverPort:(NSString*)cp
              username:(NSString*)username
             groupname:(NSString*)groupname
              delegate:(id<AMMesherOperationProtocol>)delegate
{
    if (self = [super init])
    {
        _etcdApi = [[AMETCD alloc]init];
        _etcdApi.serverIp = hostAddr;
        _etcdApi.clientPort = [cp intValue];
        
        _username = username;
        _groupname = groupname;
        
        self.delegate = delegate;
        
        _isResultOK = NO;
    }
    
    return self;
    
}

-(void)main
{
    if (self.isCancelled){return;}
    
    NSLog(@"Removing user...");
    
    int retry = 0;
    NSString* myUserDir = [NSString stringWithFormat:@"/Groups/%@/Users/%@/", _groupname, _username];
    
    for (retry=0; retry < 3; retry++)
    {
        AMETCDResult* res = [_etcdApi deleteDir:myUserDir recursive:YES];
        if(res != nil && res.errCode == 0)
        {
            retry = 0;
            break;
        }
        
        if (retry == 3)
        {
            _isResultOK = NO;
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(DeleteUserOperationDidFinish:) withObject:self waitUntilDone:NO];
            return;
        }
    }
    
    _isResultOK = YES;
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(DeleteUserOperationDidFinish:) withObject:self waitUntilDone:NO];
    
}

@end
