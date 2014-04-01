//
//  AMUpdateUserOperator.m
//  AMMesher
//
//  Created by Wei Wang on 3/30/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMUpdateUserOperator.h"
#import "AMETCDApi/AMETCD.h"

@implementation AMUpdateUserOperator
{
    AMETCD* _etcdApi;
    NSString* _username;
    NSString* _groupname;
    NSDictionary* _changedProperties;
}

-(id)initWithParameter:(NSString*)hostAddr
            serverPort:(NSString*)cp
              username:(NSString*)username
             groupname:(NSString*)groupname
     changedProperties:(NSDictionary*)keyvalues
              delegate:(id<AMMesherOperationProtocol>)delegate
{
    if (self = [super init])
    {
        _etcdApi = [[AMETCD alloc]init];
        _etcdApi.serverIp = hostAddr;
        _etcdApi.clientPort = [cp intValue];
        
        _username = username;
        _groupname = groupname;
        _changedProperties = keyvalues;
        
        self.delegate = delegate;
        
        _isResultOK = NO;
    }
    
    return self;
    
}

-(void)main
{
    if (self.isCancelled){return;}
    
    NSLog(@"Updating user information...");
    
    int retry = 0;
    
    NSString* userDir = [NSString stringWithFormat:@"/Groups/%@/Users/%@/", _groupname, _username];
    for (NSString* key in _changedProperties)
    {
        NSString* propertyVal = [_changedProperties objectForKey:key];
        NSString* propertyKey = [NSString stringWithFormat:@"%@/%@", userDir, key];
        
        for (; retry < 3; retry++)
        {
            if(self.isCancelled){return;}
            
            AMETCDResult* res = [_etcdApi setKey:propertyKey withValue:propertyVal ttl:0];
            if(res != nil && res.errCode == 0)
            {
                retry = 0;
                break;
            }
            
            if (retry == 3)
            {
                _isResultOK = NO;
                [(NSObject *)self.delegate performSelectorOnMainThread:@selector(UpdateUserOperatorDidFinish:) withObject:self waitUntilDone:NO];
                return;
            }
        }
        
    }
    
    _isResultOK = YES;
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(UpdateUserOperatorDidFinish:) withObject:self waitUntilDone:NO];
    
}




@end
