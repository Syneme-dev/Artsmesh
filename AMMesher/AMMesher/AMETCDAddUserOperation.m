//
//  AMETCDAddUserOperation.m
//  AMMesher
//
//  Created by Wei Wang on 4/7/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDAddUserOperation.h"
#import "AMETCDApi/AMETCD.h"
#import "AMETCDOperationDelegate.h"

@implementation AMETCDAddUserOperation

-(id)initWithParameter:(NSString*)ip
                  port:(NSString*)port
          fullUserName:(NSString*)fullUserName
         fullGroupName:(NSString*)fullGroupName
                   ttl:(int)ttl;
{
    if (self = [super init:ip port:port])
    {
        self.fullGroupName = fullGroupName;
        self.fullUserName  = fullUserName;
        self.ttl = ttl;
    }
    
    return self;
}

-(void)main
{
    if (self.isCancelled)
    {
        return;
    }
    
    NSLog(@"Server:%@ Adding User...", self.etcdApi.serverIp);
    int retry = 0;
    
    NSString* userDirKey = [NSString stringWithFormat:@"/Users/%@/", self.fullUserName];
    AMETCDResult* res = [self.etcdApi setDir:userDirKey ttl:self.ttl prevExist:NO];
    if (res.errCode != 0 )
    {
        for (retry = 0; retry < 3; retry++)
        {
            if(self.isCancelled)
            {
                self.isResultOK = NO;
                [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AMETCDOperationDidFinished:) withObject:self waitUntilDone:NO];
                return;
            }
            
            AMETCDResult* res = [self.etcdApi setDir:userDirKey ttl:self.ttl prevExist:NO];
            if(res.errCode == 0)
            {
                break;
            }
        }
        
        if (retry == 3)
        {
            self.isResultOK = NO;
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AMETCDOperationDidFinished:) withObject:self waitUntilDone:NO];
            return;
        }
    }
    
    NSString* groupPropKey = [NSString stringWithFormat:@"%@GroupName", userDirKey ];
    res = [self.etcdApi setKey:groupPropKey withValue:self.fullGroupName ttl:0];
    if (res.errCode != 0 )
    {
        for (retry = 0; retry < 3; retry++)
        {
            if(self.isCancelled)
            {
                self.isResultOK = NO;
                [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AMETCDOperationDidFinished:) withObject:self waitUntilDone:NO];
                return;
            }
            
            res = [self.etcdApi setKey:groupPropKey withValue:self.fullGroupName ttl:0];
            if(res.errCode == 0)
            {
                break;
            }
        }
        
        if (retry == 3)
        {
            self.isResultOK = NO;
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AMETCDOperationDidFinished:) withObject:self waitUntilDone:NO];
            return;
        }
    }
    
    NSString* groupKey = [NSString stringWithFormat:@"/Groups/%@", self.fullGroupName];
    res = [self.etcdApi setDir:groupKey ttl:self.ttl prevExist:NO];
    if (res.errCode != 0 && res.errCode != 102)
    {
        for (retry = 0; retry < 3; retry++)
        {
            if(self.isCancelled)
            {
                self.isResultOK = NO;
                [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AMETCDOperationDidFinished:) withObject:self waitUntilDone:NO];
                return;
            }
            
            res = [self.etcdApi setDir:groupKey ttl:self.ttl prevExist:NO];
            if(res.errCode == 0 || res.errCode == 102)
            {
                break;
            }
        }
        
        if (retry == 3)
        {
            self.isResultOK = NO;
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AMETCDOperationDidFinished:) withObject:self waitUntilDone:NO];
            return;
        }
    }
    
    NSString* groupStateKey = [NSString stringWithFormat:@"/Groups/%@/State", self.fullGroupName];
    res = [self.etcdApi setKey:groupStateKey withValue:@"offline" ttl:0];
    if (res.errCode != 0 && res.errCode != 102)
    {
        for (retry = 0; retry < 3; retry++)
        {
            if(self.isCancelled)
            {
                self.isResultOK = NO;
                [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AMETCDOperationDidFinished:) withObject:self waitUntilDone:NO];
                return;
            }
            
            res = [self.etcdApi setKey:groupStateKey withValue:@"offline" ttl:0];
            if(res.errCode == 0 || res.errCode == 102)
            {
                break;
            }
        }
        
        if (retry == 3)
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
