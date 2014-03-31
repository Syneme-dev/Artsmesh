//
//  AMETCDInitializer.m
//  AMMesher
//
//  Created by Wei Wang on 3/30/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDInitializer.h"
#import "AMETCDApi/AMETCD.h"

@implementation AMETCDInitializer
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
    
    int retry = 0;
    for (; retry < 3; retry++)
    {
        if(self.isCancelled){return;}
        
        AMETCDResult* res = [_etcdApi setDir:@"/Groups/" ttl:0 prevExist:NO];
        if(res != nil && res.errCode == 0)
        {
            retry = 0;
            break;
        }
        
        if (retry == 3)
        {
            _isResultOK = NO;
            return;
        }
    }
    
    for (; retry < 3; retry++)
    {
        if(self.isCancelled){return;}
        
        AMETCDResult* res = [_etcdApi setDir:@"/Groups/Artsmesh/" ttl:0 prevExist:NO];
        if(res != nil && res.errCode == 0)
        {
            retry = 0;
            break;
        }
        
        if (retry == 3)
        {
            _isResultOK = NO;
            return;
        }
    }
    
    for (; retry < 3; retry++)
    {
        if(self.isCancelled){return;}
        
        AMETCDResult* res = [_etcdApi setDir:@"/Groups/Artsmesh/Users/" ttl:0 prevExist:NO];
        if(res != nil && res.errCode == 0)
        {
            retry = 0;
            break;
        }
        
        if (retry == 3)
        {
            _isResultOK = NO;
            return;
        }
    }
    
    for (; retry < 3; retry++)
    {
        if(self.isCancelled){return;}
        
        AMETCDResult* res = [_etcdApi setKey:@"/Groups/Artsmesh/description/" withValue:@"This is default group" ttl:0];
        if(res != nil && res.errCode == 0)
        {
            retry = 0;
            break;
        }
        
        if (retry == 3)
        {
            _isResultOK = NO;
            return;
        }
    }
    
    _isResultOK = YES;
    
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(ETCDInitializerDidFinish:) withObject:self waitUntilDone:NO];
}

@end
