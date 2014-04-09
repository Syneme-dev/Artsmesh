//
//  AMETCDUpdateGroupOperation.m
//  AMMesher
//
//  Created by Wei Wang on 4/7/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDUpdateGroupOperation.h"
#import "AMETCDApi/AMETCD.h"
#import "AMETCDOperationDelegate.h"

@implementation AMETCDUpdateGroupOperation

-(id)initWithParameter:(NSString*)ip
                  port:(NSString*)port
         fullGroupName:(NSString*)fullGroupName
       groupProperties:(NSDictionary*)properties
{
    if (self = [super init:ip port:port])
    {
        self.fullGroupName = fullGroupName;
        self.properties = properties;
    }
    
    return self;
}

-(void)main
{
    if (self.isCancelled){return;}
    
    NSLog(@"Updating Group...");
    int retry = 0;
    
    NSString* groupDir = [NSString stringWithFormat:@"/Groups/%@/", self.fullGroupName];
    
    if (self.properties != nil)
    {
        for (NSString* propertyName in self.properties)
        {
            NSString* propertyVal = [self.properties valueForKey:propertyName];
            NSString* propertyPath = [NSString stringWithFormat:@"%@%@", groupDir, propertyName];
            
            AMETCDResult* res = [self.etcdApi setKey:propertyPath withValue:propertyVal ttl:0];
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
                    
                    res = [self.etcdApi setKey:propertyPath withValue:propertyVal ttl:0];
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
        }

    }
    
    self.isResultOK = YES;
    
    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(AMETCDOperationDidFinished:) withObject:self waitUntilDone:NO];
}


@end
