//
//  AMETCDDeleteUserOperation.m
//  AMMesher
//
//  Created by Wei Wang on 4/7/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDDeleteUserOperation.h"
#import "AMETCDApi/AMETCD.h"
#import "AMETCDOperationDelegate.h"

@implementation AMETCDDeleteUserOperation

-(id)initWithParameter:(NSString*)ip
                  port:(NSString*)port
          fullUserName:(NSString*)fullUserName
         fullGroupName:(NSString*)fullGroupName
{
    if (self = [super init:ip port:port])
    {
        self.fullUserName = fullUserName;
        self.fullGroupName = fullGroupName;
    }
    
    return self;
}

-(void)main
{
    if (self.isCancelled){return;}
    
    NSLog(@"Removing user...");
    
    NSString* myUserDir = [NSString stringWithFormat:@"/Groups/%@/Users/%@/", self.fullUserName, self.fullUserName];
    
    AMETCDResult* res = [self.etcdApi deleteDir:myUserDir recursive:YES];
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
