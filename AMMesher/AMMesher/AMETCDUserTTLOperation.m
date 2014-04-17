//
//  AMETCDUserTTLOperation.m
//  AMMesher
//
//  Created by 王 为 on 4/8/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDOperation.h"
#import "AMETCDUserTTLOperation.h"
#import "AMETCDApi/AMETCD.h"


@implementation AMETCDUserTTLOperation

-(id)initWithParameter:(NSString*)ip
                  port:(NSString*)port
          fullUserName:(NSString*)fullUserName
                   ttl:(int)ttl
{
    if (self = [super init:ip port:port])
    {
        self.fullUserName = fullUserName;
        self.ttl = ttl;
    }
    
    return self;
}

-(void)main
{
    if (self.isCancelled)
    {
        self.isResultOK = NO;
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AMETCDOperationDidFinished:) withObject:self waitUntilDone:NO];
        return;
    }

     NSLog(@"Server:%@ TTL user...", self.etcdApi.serverIp);
    
    NSString* userDir = [NSString stringWithFormat:@"/Users/%@/", self.fullUserName];
    
    self.operationResult = [self.etcdApi setDir:userDir ttl:self.ttl prevExist:YES];
    if (self.operationResult.errCode == 0)
    {
        self.isResultOK = YES;
    }
    else
    {
        self.operationResult = [self.etcdApi setDir:userDir ttl:self.ttl prevExist:NO];
        if (self.operationResult.errCode == 0)
        {
            self.isResultOK = YES;
        }
        else
        {
            self.isResultOK = NO;
        }
    }
    
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AMETCDOperationDidFinished:) withObject:self waitUntilDone:NO];
    
}


@end
