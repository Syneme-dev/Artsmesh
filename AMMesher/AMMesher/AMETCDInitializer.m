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
    
    NSLog(@"Initializing ETCD data...");
    
    int ret = [self createDir:@"/Groups/"];
    if (ret != 0)
    {
        _isResultOK = NO;
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(ETCDInitializerDidFinish:) withObject:self waitUntilDone:NO];
        return;
    }

    ret = [self createDir:@"/Groups/Artsmesh/"];
    if (ret != 0)
    {
        _isResultOK = NO;
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(ETCDInitializerDidFinish:) withObject:self waitUntilDone:NO];
        return;
    }
    
    ret = [self createDir:@"/Groups/Performance/"];
    if (ret != 0)
    {
        _isResultOK = NO;
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(ETCDInitializerDidFinish:) withObject:self waitUntilDone:NO];
        return;
    }
    
    ret = [self createDir:@"/Groups/Artsmesh/Users/"];
    if (ret != 0)
    {
        _isResultOK = NO;
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(ETCDInitializerDidFinish:) withObject:self waitUntilDone:NO];
        return;
    }
    
    ret = [self createDir:@"/Groups/Performance/Users/"];
    if (ret != 0)
    {
        _isResultOK = NO;
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(ETCDInitializerDidFinish:) withObject:self waitUntilDone:NO];
        return;
    }
    
    ret = [self createKey:@"/Groups/Artsmesh/description" withValue:@"this is chat group"];
    if (ret != 0)
    {
        _isResultOK = NO;
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(ETCDInitializerDidFinish:) withObject:self waitUntilDone:NO];
        return;
    }
    
    ret = [self createKey:@"/Groups/Performance/description" withValue:@"this is chat group"];
    if (ret != 0)
    {
        _isResultOK = NO;
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(ETCDInitializerDidFinish:) withObject:self waitUntilDone:NO];
        return;
    }
    
    ret = [self createKey:@"/Groups/Artsmesh/name" withValue:@"Artsmesh"];
    if (ret != 0)
    {
        _isResultOK = NO;
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(ETCDInitializerDidFinish:) withObject:self waitUntilDone:NO];
        return;
    }
    
    ret = [self createKey:@"/Groups/Performance/name" withValue:@"CCOMPref"];
    if (ret != 0)
    {
        _isResultOK = NO;
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(ETCDInitializerDidFinish:) withObject:self waitUntilDone:NO];
        return;
    }
    
    _isResultOK = YES;
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(ETCDInitializerDidFinish:) withObject:self waitUntilDone:NO];
}

//0 succeeded 1 canceled -1 error
-(int)createDir:(NSString*)dirPath
{
    AMETCDResult* res = [_etcdApi setDir:dirPath ttl:0 prevExist:NO];

    if(res.errCode != 0)
    {
        int retry = 0;
        for (; retry < 3; retry++)
        {
            if(self.isCancelled){return 1;}
            
            AMETCDResult* res = [_etcdApi setDir:dirPath ttl:0 prevExist:NO];
            if(res != nil && res.errCode == 0)
            {
                return 0;
            }
        }
        
        return -1;
    }
    
    return 0;
}

-(int)createKey:(NSString*)keyPath withValue:(NSString*)val
{
    
    AMETCDResult* res = [_etcdApi setKey:keyPath withValue:val ttl:0];
    if(res.errCode != 0)
    {
        int retry = 0;
        for (; retry < 3; retry++)
        {
            if(self.isCancelled){return 1;}
            
            AMETCDResult* res = [_etcdApi setKey:keyPath withValue:val ttl:0];
            if(res != nil && res.errCode == 0)
            {
                return 0;
            }
        }
        
        return -1;
    }
    
    return 0;
}

@end
