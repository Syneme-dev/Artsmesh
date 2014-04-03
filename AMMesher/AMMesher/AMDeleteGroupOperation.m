//
//  AMDeleteGroupOperation.h
//  AMMesher
//
//  Created by 王 为 on 4/3/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMDeleteGroupOperation.h"
#import "AMETCDApi/AMETCD.h"
#import "AMMesherOperationProtocol.h"

@implementation AMDeleteGroupOperation
{
    AMETCD* _etcdApi;
    NSString* _groupname;
}

-(id)initWithParameter:(NSString*)hostAddr
            serverPort:(NSString*)cp
             groupname:(NSString*)groupname
              delegate:(id<AMMesherOperationProtocol>)delegate
{
    if (self = [super init])
    {
        _etcdApi = [[AMETCD alloc]init];
        _etcdApi.serverIp = hostAddr;
        _etcdApi.clientPort = [cp intValue];
        
        _groupname = groupname;
        self.delegate = delegate;
        
        _isResultOK = NO;
    }
    
    return self;
}

-(void)main
{
    if (self.isCancelled){return;}
    
    NSLog(@"Deleting Group...");
    int retry = 0;
    
    NSString* groupDir = [NSString stringWithFormat:@"/Groups/%@", _groupname];
    AMETCDResult* res = [_etcdApi deleteDir:groupDir recursive:YES];
    if (res.errCode != 0 )
    {
        for (; retry < 3; retry++)
        {
            if(self.isCancelled)
            {
                _isResultOK = NO;
                [(NSObject *)self.delegate performSelectorOnMainThread:@selector(DeleteGroupOperationDidFinish:) withObject:self waitUntilDone:NO];
                return;
            }
            
            res = [_etcdApi deleteDir:groupDir recursive:YES];
            if(res.errCode == 0)
            {
                retry = 0;
                break;
            }
        }
        
        if (retry == 3)
        {
            _isResultOK = NO;
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(DeleteGroupOperationDidFinish:) withObject:self waitUntilDone:NO];
            return;
        }
    }
    
    _isResultOK = YES;
    
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(DeleteGroupOperationDidFinish:) withObject:self waitUntilDone:NO];
    
}



@end
