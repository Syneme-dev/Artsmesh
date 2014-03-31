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
    
    int retry = 0;
    
    NSString* myGroupDir = [NSString stringWithFormat:@"/Groups/%@/", _groupname];
    AMETCDResult* res = [_etcdApi listDir:myGroupDir recursive:NO];
    if (res.errCode !=0 )
    {
        for (; retry < 3; retry++)
        {
            if(self.isCancelled){return;}
            
            AMETCDResult* res = [_etcdApi setDir:myGroupDir ttl:0 prevExist:NO];
            if(res != nil && res.errCode == 0)
            {
                retry = 0;
                break;
            }
            
            if (retry == 3)
            {
                _isResultOK = NO;
                [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AddUserOperatorDidFinish:) withObject:self waitUntilDone:NO];
                return;
            }
        }
    }
   
    NSString* myUserDir = [NSString stringWithFormat:@"/Groups/%@/Users/%@/", _groupname, _username];
    
    for (; retry < 3; retry++)
    {
        if(self.isCancelled){return;}
        
        AMETCDResult* res = [_etcdApi setDir:myUserDir ttl:30 prevExist:NO];
        if(res != nil && res.errCode == 0)
        {
            retry = 0;
            break;
        }
        
        if (retry == 3)
        {
            _isResultOK = NO;
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AddUserOperatorDidFinish:) withObject:self waitUntilDone:NO];
            return;
        }
    }
    
    NSString* myip = [NSString stringWithFormat:@"%@/ip", myUserDir];

    for (; retry < 3; retry++)
    {
        if(self.isCancelled){return;}
        
        AMETCDResult* res = [_etcdApi setKey:myip withValue:_userip ttl:0];
        if(res != nil && res.errCode == 0)
        {
            retry = 0;
            break;
        }
        
        if (retry == 3)
        {
            _isResultOK = NO;
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AddUserOperatorDidFinish:) withObject:self waitUntilDone:NO];
            return;
        }
    }
    
    NSString* domain = [NSString stringWithFormat:@"%@/domain", myUserDir];
    
    for (; retry < 3; retry++)
    {
        if(self.isCancelled){return;}
        
        AMETCDResult* res = [_etcdApi setKey:domain withValue:_userdomain ttl:0];
        if(res != nil && res.errCode == 0)
        {
            retry = 0;
            break;
        }
        
        if (retry == 3)
        {
            _isResultOK = NO;
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AddUserOperatorDidFinish:) withObject:self waitUntilDone:NO];
            return;
        }
    }
    
    NSString* status = [NSString stringWithFormat:@"%@/status", myUserDir];
    
    for (; retry < 3; retry++)
    {
        if(self.isCancelled){return;}
        
        AMETCDResult* res = [_etcdApi setKey:status withValue:_userStatus ttl:0];
        if(res != nil && res.errCode == 0)
        {
            retry = 0;
            break;
        }
        
        if (retry == 3)
        {
            _isResultOK = NO;
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AddUserOperatorDidFinish:) withObject:self waitUntilDone:NO];
            return;
        }
    }
    
    NSString* dis = [NSString stringWithFormat:@"%@/description", myUserDir];
    for (; retry < 3; retry++)
    {
        if(self.isCancelled){return;}
        
        AMETCDResult* res = [_etcdApi setKey:dis withValue:_userDiscription ttl:0];
        if(res != nil && res.errCode == 0)
        {
            retry = 0;
            break;
        }
        
        if (retry == 3)
        {
            _isResultOK = NO;
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AddUserOperatorDidFinish:) withObject:self waitUntilDone:NO];
            return;
        }
    }
    
    _isResultOK = YES;
    
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AddUserOperatorDidFinish:) withObject:self waitUntilDone:NO];

}

@end
