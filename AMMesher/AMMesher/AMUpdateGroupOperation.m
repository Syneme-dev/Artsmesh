//
//  AMUpdateGroupOperation.m
//  AMMesher
//
//  Created by 王 为 on 4/3/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMUpdateGroupOperation.h"
#import "AMETCDApi/AMETCD.h"
#import "AMMesherOperationProtocol.h"

@implementation AMUpdateGroupOperation
{
    AMETCD* _etcdApi;
    NSString* _groupname;
    NSDictionary* _groupProperties;
}

-(id)initWithParameter:(NSString*)hostAddr
            serverPort:(NSString*)cp
             groupname:(NSString*)groupname
       groupProperties:(NSDictionary*)properties
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
        
        _isResultOK = NO;
    }
    
    return self;
}

-(void)main
{
    if (self.isCancelled){return;}
    
    NSLog(@"Updating Group...");
    int retry = 0;
    
    NSString* groupDir = [NSString stringWithFormat:@"/Groups/%@/", _groupname];
    
    for (NSString* propertyName in _groupProperties)
    {
        NSString* propertyVal = [_groupProperties valueForKey:propertyName];
        NSString* propertyPath = [NSString stringWithFormat:@"%@%@", groupDir, propertyName];
        
        AMETCDResult* res = [_etcdApi setKey:propertyPath withValue:propertyVal ttl:0];
        if (res.errCode != 0 )
        {
            for (retry = 0; retry < 3; retry++)
            {
                if(self.isCancelled)
                {
                    _isResultOK = NO;
                    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(UpdateGroupOperationDidFinish:) withObject:self waitUntilDone:NO];
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
                [(NSObject *)self.delegate performSelectorOnMainThread:@selector(UpdateGroupOperationDidFinish:) withObject:self waitUntilDone:NO];
                return;
            }
        }
    }
    
    _isResultOK = YES;
    
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(UpdateGroupOperationDidFinish:) withObject:self waitUntilDone:NO];
    
}


@end
