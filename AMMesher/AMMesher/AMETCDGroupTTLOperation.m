//
//  AMETCDGroupTTLOperation.m
//  AMMesher
//
//  Created by 王 为 on 4/8/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDGroupTTLOperation.h"
#import "AMETCDApi/AMETCD.h"

@implementation AMETCDGroupTTLOperation

-(id)initWithParameter:(NSString*)ip
                  port:(NSString*)port
         fullGroupName:(NSString*)fullGroupName
                   ttl:(int)ttl;
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
    
    NSLog(@"Updating TTL information...");
    
    int retry = 0;
    
    NSString* userDir = [NSString stringWithFormat:@"/Groups/%@/", self.fullGroupName];
    
    for (retry = 0; retry < 3; retry++)
    {
        if(self.isCancelled){return;}
        
        AMETCDResult* res = [self.etcdApi setDir:userDir ttl:self.ttl prevExist:YES];
        if(res != nil && res.errCode == 0)
        {
            retry = 0;
            break;
        }
    }
    
    if (retry == 3)
    {
        self.isResultOK = NO;
        return;
    }
    
    self.isResultOK = YES;
}



@end
