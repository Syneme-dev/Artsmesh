//
//  AMETCDUpdateUserOperation.m
//  AMMesher
//
//  Created by Wei Wang on 4/7/14.
//  Copyright (c) 2014 AM. All rights reserved.
//
#import "AMETCDOperation.h"
#import "AMETCDUpdateUserOperation.h"
#import "AMETCDApi/AMETCD.h"

@implementation AMETCDUpdateUserOperation

-(id)initWithParameter:(NSString*)ip
                  port:(NSString*)port
          fullUserName:(NSString*)fullUserName
        userProperties:(NSDictionary *)properties
{
    if (self = [super init:ip port:port])
    {
        self.fullUserName = fullUserName;
        self.properties = properties;
    }
    
    return self;
    
}

-(void)main
{
    if (self.isCancelled){return;}

     NSLog(@"Server:%@ Updating user...", self.etcdApi.serverIp);
    
    int retry = 0;
    
    NSString* userDir = [NSString stringWithFormat:@"/Users/%@/", self.fullUserName];
    
    if (self.properties != nil)
    {
        for (NSString* key in self.properties)
        {
            NSString* propertyVal = [self.properties objectForKey:key];
            NSString* propertyKey = [NSString stringWithFormat:@"%@/%@", userDir, key];
            
            for (retry = 0; retry < 3; retry++)
            {
                if(self.isCancelled){return;}
                
                self.operationResult = [self.etcdApi setKey:propertyKey withValue:propertyVal ttl:0];
                if(self.operationResult != nil && self.operationResult.errCode == 0)
                {
                    retry = 0;
                    break;
                }
                
                if (retry == 3)
                {
                    self.isResultOK= NO;
                    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AMETCDOperationDidFinished:) withObject:self waitUntilDone:NO];
                    return;
                }
            }
        }

    }
    
    self.isResultOK = YES;
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AMETCDOperationDidFinished:) withObject:self waitUntilDone:NO];
}



@end
