//
//  AMAddUserOperator.m
//  AMMesher
//
//  Created by Wei Wang on 3/30/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMAddUserOperator.h"
#import "AMETCDApi/AMETCD.h"

@implementation AMAddUserOperator
{
    AMETCD* _etcdApi;
    NSString* _username;
    NSString* _groupname;
    NSString* _userdomain;
    NSString* _userip;
    NSString* _userStatus;
    NSString* _userDiscription;
    
}

-(id)initWithParameter:(NSString*)hostAddr
            serverPort:(NSString*)cp
              username:(NSString*)username
             groupname:(NSString*)groupname
            userdomain:(NSString*)userdomain
                userip:(NSString*)userip
            userStatus:(NSString*)userStatus
       userDiscription:(NSString*)userDiscription
              delegate:(id<AMMesherOperationProtocol>)delegate
{
    if (self = [super init])
    {
        _etcdApi = [[AMETCD alloc]init];
        _etcdApi.serverIp = hostAddr;
        _etcdApi.clientPort = [cp intValue];
        
        _username = username;
        _groupname = groupname;
        _userdomain = userdomain;
        _userip = userip;
        _userStatus = userStatus;
        _userDiscription = userDiscription;
        
        self.delegate = delegate;
    
        _isResultOK = NO;
    }
    
    return self;
}

-(void)main
{
    if (self.isCancelled){return;}
    
    NSLog(@"Adding User...");
    int retry = 0;
    
    
    NSString* userDirKey = [NSString stringWithFormat:@"/Groups/%@/Users/%@", _groupname, _username];
    AMETCDResult* res = [_etcdApi setDir:userDirKey ttl:30 prevExist:NO];
    if (res.errCode != 0 )
    {
        for (; retry < 3; retry++)
        {
            if(self.isCancelled)
            {
                _isResultOK = NO;
                [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AddUserOperatorDidFinish:) withObject:self waitUntilDone:NO];
                return;
            }
            
            AMETCDResult* res = [_etcdApi setDir:userDirKey ttl:30 prevExist:NO];
            if(res.errCode == 0)
            {
                retry = 0;
                break;
            }
        }
        
        if (retry == 3)
        {
            _isResultOK = NO;
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AddUserOperatorDidFinish:) withObject:self waitUntilDone:NO];
            return;
        }
    }
    
    
    NSString* myip = [NSString stringWithFormat:@"%@/ip", userDirKey];

    for (; retry < 3; retry++)
    {
        if(self.isCancelled){return;}
        
        AMETCDResult* res = [_etcdApi setKey:myip withValue:_userip ttl:0];
        if(res != nil && res.errCode == 0)
        {
            retry = 0;
            break;
        }
    }
    
    if (retry == 3)
    {
        _isResultOK = NO;
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AddUserOperatorDidFinish:) withObject:self waitUntilDone:NO];
        return;
    }
    
    NSString* domain = [NSString stringWithFormat:@"%@/domain", userDirKey];
    
    for (; retry < 3; retry++)
    {
        if(self.isCancelled){return;}
        
        AMETCDResult* res = [_etcdApi setKey:domain withValue:_userdomain ttl:0];
        if(res != nil && res.errCode == 0)
        {
            retry = 0;
            break;
        }
    }
    if (retry == 3)
    {
        _isResultOK = NO;
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AddUserOperatorDidFinish:) withObject:self waitUntilDone:NO];
        return;
    }
    
    
    NSString* status = [NSString stringWithFormat:@"%@/status", userDirKey];
    for (; retry < 3; retry++)
    {
        if(self.isCancelled){return;}
        
        AMETCDResult* res = [_etcdApi setKey:status withValue:_userStatus ttl:0];
        if(res != nil && res.errCode == 0)
        {
            retry = 0;
            break;
        }
    }
    
    if (retry == 3)
    {
        _isResultOK = NO;
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AddUserOperatorDidFinish:) withObject:self waitUntilDone:NO];
        return;
    }
    
    NSString* desc = [NSString stringWithFormat:@"%@/description", userDirKey];
    
    for (; retry < 3; retry++)
    {
        if(self.isCancelled){return;}
        
        AMETCDResult* res = [_etcdApi setKey:desc withValue:_userDiscription ttl:0];
        if(res != nil && res.errCode == 0)
        {
            retry = 0;
            break;
        }
    }
    if (retry == 3)
    {
        _isResultOK = NO;
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AddUserOperatorDidFinish:) withObject:self waitUntilDone:NO];
        return;
    }
    
    _isResultOK = YES;
    
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AddUserOperatorDidFinish:) withObject:self waitUntilDone:NO];

}


@end
