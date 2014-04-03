//
//  AMAddUserOperation.m
//  AMMesher
//
//  Created by Wei Wang on 3/30/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMAddUserOperation.h"
#import "AMETCDApi/AMETCD.h"

@implementation AMAddUserOperation
{
    AMETCD* _etcdApi;
    NSString* _username;
    NSString* _groupname;
    NSDictionary* _userProperties;
    int _ttl;
}

-(id)initWithParameter:(NSString*)hostAddr
            serverPort:(NSString*)cp
              username:(NSString*)username
             groupname:(NSString*)groupname
        userProperties:(NSDictionary*)properties
                   ttl:(int)ttl
              delegate:(id<AMMesherOperationProtocol>)delegate
{
    if (self = [super init])
    {
        _etcdApi = [[AMETCD alloc]init];
        _etcdApi.serverIp = hostAddr;
        _etcdApi.clientPort = [cp intValue];
        
        _username = username;
        _groupname = groupname;
        _userProperties = properties;
        _ttl = ttl;
        
        self.delegate = delegate;
    
        _isResultOK = NO;
    }
    
    return self;
}

-(void)main
{
    if (self.isCancelled)
    {
        return;
    }
    
    NSLog(@"Adding User...");
    int retry = 0;

    NSString* userDirKey = [NSString stringWithFormat:@"/Groups/%@/Users/%@", _groupname, _username];
    AMETCDResult* res = [_etcdApi setDir:userDirKey ttl:30 prevExist:NO];
    if (res.errCode != 0 )
    {
        for (retry = 0; retry < 3; retry++)
        {
            if(self.isCancelled)
            {
                _isResultOK = NO;
                [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AddUserOperationDidFinish:) withObject:self waitUntilDone:NO];
                return;
            }
            
            AMETCDResult* res = [_etcdApi setDir:userDirKey ttl:_ttl prevExist:NO];
            if(res.errCode == 0)
            {
                retry = 0;
                break;
            }
        }
        
        if (retry == 3)
        {
            _isResultOK = NO;
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AddUserOperationDidFinish:) withObject:self waitUntilDone:NO];
            return;
        }
    }
    
    
    for (NSString* propertyName in _userProperties)
    {
        NSString* propertyKey = [NSString stringWithFormat:@"%@/%@", userDirKey, propertyName];
        NSString* propertyVal = [_userProperties valueForKey:propertyName];
        
        for (retry = 0; retry < 3; retry++)
        {
            if(self.isCancelled)
            {
                _isResultOK = NO;
                [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AddUserOperationDidFinish:) withObject:self waitUntilDone:NO];
                return;
            }
            
            AMETCDResult* res = [_etcdApi setKey:propertyKey withValue:propertyVal ttl:0];
            if(res != nil && res.errCode == 0)
            {
                break;
            }
        }
        
        if (retry == 3)
        {
            _isResultOK = NO;
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AddUserOperationDidFinish:) withObject:self waitUntilDone:NO];
            return;
        }
    }
    
    _isResultOK = YES;
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AddUserOperationDidFinish:) withObject:self waitUntilDone:NO];

}


@end
