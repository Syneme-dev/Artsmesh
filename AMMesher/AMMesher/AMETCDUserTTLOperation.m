//
//  AMETCDUserTTLOperation.m
//  AMMesher
//
//  Created by 王 为 on 4/8/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDUserTTLOperation.h"
#import "AMETCDApi/AMETCD.h"
#import "AMETCDOperationDelegate.h"

@implementation AMETCDUserTTLOperation

-(id)initWithParameter:(NSString*)ip
                  port:(NSString*)port
          fullUserName:(NSString*)fullUserName
         fullGroupName:(NSString*)fullGroupName
                   ttl:(int)ttl
{
    if (self = [super init:ip port:port])
    {
        self.fullGroupName = fullGroupName;
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
    
    NSLog(@"Updating TTL information...");
    
    NSString* userDir = [NSString stringWithFormat:@"/Groups/%@/Users/%@/", self.fullGroupName, self.fullUserName];
    
    AMETCDResult* res = [self.etcdApi setDir:userDir ttl:self.ttl prevExist:YES];
    if (res.errCode == 0)
    {
        self.isResultOK = YES;
    }
    else
    {
        self.isResultOK = NO;
    }
    
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AMETCDOperationDidFinished:) withObject:self waitUntilDone:NO];
    
}


@end
