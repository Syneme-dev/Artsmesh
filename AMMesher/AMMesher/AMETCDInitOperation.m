//
//  AMETCDInitOperation.m
//  AMMesher
//
//  Created by 王 为 on 4/9/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDInitOperation.h"
#import "AMETCDApi/AMETCD.h"
#import "AMETCDOperationHeader.h"

@implementation AMETCDInitOperation

-(id)initWithEtcdServer:(NSString*)ip
                   port:(NSString*)port
{
    if(self = [super init:ip port:port])
    {
        self.operationType = @"init";
    }
    
    return self;
}-(void)main
{
    if(self.isCancelled){return;}
    
    NSLog(@"Initializing ETCD data...");
    
    AMETCDResult* res = [self.etcdApi setDir:@"/Groups/" ttl:0 prevExist:NO];
    if(res.errCode != 0)
    {
        int retry = 0;
        for (; retry < 3; retry++)
        {
            if(self.isCancelled)
            {
                self.isResultOK = NO;
                [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AMETCDOperationDidFinished:) withObject:self waitUntilDone:NO];
                return;
            }
            
            res = [self.etcdApi setDir:@"/Groups/" ttl:0 prevExist:NO];
            if(res.errCode == 0)
            {
                break;
            }
        }
        
        if(retry == 3)
        {
            self.isResultOK = NO;
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AMETCDOperationDidFinished:) withObject:self waitUntilDone:NO];
            return;
        }
    }
    
    self.isResultOK = YES;
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AMETCDOperationDidFinished:) withObject:self waitUntilDone:NO];
}


@end
