//
//  AMETCDDeleteGroupOperation.m
//  AMMesher
//
//  Created by Wei Wang on 4/7/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDDeleteGroupOperation.h"
#import "AMETCDApi/AMETCD.h"
#import "AMETCDOperationDelegate.h"

@implementation AMETCDDeleteGroupOperation

-(id)initWithParameter:(NSString*)ip
                  port:(NSString*)port
             fullGroupName:(NSString*)fullGroupName
{
    if (self = [super init:ip port:port])
    {
        self.fullGroupName = fullGroupName;
    }
    
    return self;
}

-(void)main
{
    if (self.isCancelled){return;}
    
    NSLog(@"Deleting Group...");
    int retry = 0;
    
    NSString* groupDir = [NSString stringWithFormat:@"/Groups/%@", self.fullGroupName ];
    AMETCDResult* res = [self.etcdApi deleteDir:groupDir recursive:YES];
    if (res.errCode != 0 )
    {
        for (; retry < 3; retry++)
        {
            if(self.isCancelled)
            {
                self.isResultOK = NO;
                [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AMETCDOperationDidFinished:) withObject:self waitUntilDone:NO];
                return;
            }
            
            res = [self.etcdApi deleteDir:groupDir recursive:YES];
            if(res.errCode == 0)
            {
                self.isResultOK = YES;
                [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AMETCDOperationDidFinished:) withObject:self waitUntilDone:NO];

                return;
            }
        }
        
        if (retry == 3)
        {
            self.isResultOK = NO;
            [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AMETCDOperationDidFinished:) withObject:self waitUntilDone:NO];
            return;
        }
    }
    
}


@end
