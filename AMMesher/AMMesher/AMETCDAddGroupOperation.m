//
//  AMETCDAddGroupOperation.m
//  AMMesher
//
//  Created by Wei Wang on 4/7/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDAddGroupOperation.h"
#import "AMETCDApi/AMETCD.h"
#import "AMETCDOperationDelegate.h"

@implementation AMETCDAddGroupOperation

-(id)initWithParameter:(NSString*)ip
                  port:(NSString*)port
             fullGroupName:(NSString*)fullGroupName
                   ttl:(int)ttl
{
    if (self = [super init:ip port:port])
    {
        self.fullGroupName = fullGroupName;
        self.ttl = ttl;
    }
    
    return self;
}

-(void)main
{
    if (self.isCancelled){return;}
    
    NSLog(@"Server:%@ Adding Group...", self.etcdApi.serverIp);
    int retry = 0;
    
    NSString* groupDir = [NSString stringWithFormat:@"/Groups/%@/", self.fullGroupName];
    AMETCDResult* res = [self.etcdApi setDir:groupDir ttl:self.ttl prevExist:NO];
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
            
            res = [self.etcdApi setDir:groupDir ttl:self.ttl prevExist:NO];
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
    
    self.isResultOK = YES;
    
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AMETCDOperationDidFinished:) withObject:self waitUntilDone:NO];
    
}


@end
