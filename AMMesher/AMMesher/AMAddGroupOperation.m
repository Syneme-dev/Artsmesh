//
//  AMAddGroupOperation.m
//  AMMesher
//
//  Created by 王 为 on 4/3/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMAddGroupOperation.h"
#import "AMETCDApi/AMETCD.h"
#import "AMMesherOperationProtocol.h"

@implementation AMAddGroupOperation
{
    AMETCD* _etcdApi;
    NSString* _groupname;
    int _ttl;
    NSDictionary* _groupProperties;
}

-(id)initWithParameter:(NSString*)hostAddr
            serverPort:(NSString*)cp
             groupname:(NSString*)groupname
       groupProperties:(NSDictionary*)properties
                   ttl:(int)ttl
              delegate:(id<AMMesherOperationProtocol>)delegate
{
    if (self = [super init])
    {
        _etcdApi = [[AMETCD alloc]init];
        _etcdApi.serverIp = hostAddr;
        _etcdApi.clientPort = [cp intValue];
    
        _groupname = groupname;
        _groupProperties = properties;
        self.delegate = delegate;
        _ttl = ttl;
        
        _isResultOK = NO;
    }
    
    return self;
}

-(void)main
{
    if (self.isCancelled){return;}
    
    NSLog(@"Server:%@ Adding Group...", _etcdApi.serverIp);
    int retry = 0;
    
    NSString* groupDir = [NSString stringWithFormat:@"/Groups/%@/", _groupname];
    AMETCDResult* res = [_etcdApi setDir:groupDir ttl:_ttl prevExist:NO];
    if (res.errCode != 0 )
    {
        for (retry = 0; retry < 3; retry++)
        {
            if(self.isCancelled)
            {
                _isResultOK = NO;
                [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AddGroupOperationDidFinish:) withObject:self waitUntilDone:NO];
                return;
            }
            
            res = [_etcdApi setDir:groupDir ttl:_ttl prevExist:NO];
            if(res.errCode == 0)
            {
                break;
            }
        }
        
        if (retry == 3)
        {
            _isResultOK = NO;
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AddGroupOperationDidFinish:) withObject:self waitUntilDone:NO];
            return;
        }
    }
    
    
    for (NSString* propertyName in _groupProperties)
    {
        NSString* propertyVal = [_groupProperties valueForKey:propertyName];
        NSString* propertyPath = [NSString stringWithFormat:@"%@%@", groupDir,propertyName];
        
        AMETCDResult* res = [_etcdApi setKey:propertyPath withValue:propertyVal ttl:0];
        if (res.errCode != 0 )
        {
            for (retry = 0; retry < 3; retry++)
            {
                if(self.isCancelled)
                {
                    _isResultOK = NO;
                    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AddGroupOperationDidFinish:) withObject:self waitUntilDone:NO];
                    return;
                }
                
                res = [_etcdApi setKey:propertyPath withValue:propertyVal ttl:0];
                if(res.errCode == 0)
                {
                    break;
                }
            }
            
            if (retry == 3)
            {
                _isResultOK = NO;
                [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AddGroupOperationDidFinish:) withObject:self waitUntilDone:NO];
                return;
            }
        }
    }
    
    _isResultOK = YES;
    
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AddGroupOperationDidFinish:) withObject:self waitUntilDone:NO];
    
}

@end
