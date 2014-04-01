//
//  AMRemoveUserOperator.m
//  AMMesher
//
//  Created by Wei Wang on 3/30/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMRemoveUserOperator.h"
#import "AMETCDApi/AMETCD.h"

@implementation AMRemoveUserOperator
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
    
    for (; retry < 3; retry++)
    {
        //if(self.isCancelled){return;}
        
        AMETCDResult* res = [_etcdApi deleteDir:myUserDir recursive:YES];
        if(res != nil && res.errCode == 0)
        {
            retry = 0;
            break;
        }
        
        if (retry == 3)
        {
            _isResultOK = NO;
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(RemoveUserOperatorDidFinish:) withObject:self waitUntilDone:NO];
            return;
        }
    }
    
    
    BOOL hasUsers;
    NSString* groupUsersDir = [NSString stringWithFormat:@"/Groups/%@/Users", _groupname];
    for (; retry < 3; retry++)
    {
        // if(self.isCancelled){return;}
        
        AMETCDResult* res = [_etcdApi listDir:groupUsersDir recursive:NO];
        if(res != nil && res.errCode == 0)
        {
            if (res.node.nodes != nil && [res.node.nodes count] != 0)
            {
                hasUsers = YES;
            }
            else
            {
                hasUsers =NO;
            }
            
            break;
        }
        
        if (retry == 3)
        {
            _isResultOK = NO;
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(RemoveUserOperatorDidFinish:) withObject:self waitUntilDone:NO];
            return;
        }
    }
    
    if(!hasUsers)
    {
        for (; retry < 3; retry++)
        {
            //if(self.isCancelled){return;}
            
            AMETCDResult* res = [_etcdApi deleteDir:groupUsersDir recursive:YES];
            if(res != nil && res.errCode == 0)
            {
                retry = 0;
                break;
            }
            
            if (retry == 3)
            {
                _isResultOK = NO;
                [(NSObject *)self.delegate performSelectorOnMainThread:@selector(RemoveUserOperatorDidFinish:) withObject:self waitUntilDone:NO];
                return;
            }
        }
    }
    
    
    _isResultOK = YES;
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(RemoveUserOperatorDidFinish:) withObject:self waitUntilDone:NO];
    
}

@end
