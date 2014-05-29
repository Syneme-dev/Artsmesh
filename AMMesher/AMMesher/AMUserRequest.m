//
//  AMUserRequest.m
//  AMMesher
//
//  Created by Wei Wang on 5/29/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMUserRequest.h"

@implementation AMUserRequest

-(void)main{
    if (self.isCancelled) {
        if ([self.delegate respondsToSelector:@selector(userRequestDidCancel)])
            [self.delegate userRequestDidCancel];
        return;
    }
    
    if (![self.delegate respondsToSelector:@selector(httpServerURL)]) {
        return;
    }
    
    NSString* strURL = [self.delegate httpServerURL];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:strURL]];
    [request setHTTPMethod:@"GET"];
    
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil error:nil];
    
    if (self.isCancelled) {
        if ([self.delegate respondsToSelector:@selector(userRequestDidCancel)])
            [self.delegate userRequestDidCancel];
        return;
    }
    
    if (returnData == nil) {
        if ([self.delegate respondsToSelector:@selector(userrequest:didFailWithError:)]) {
            
            NSError *error = [NSError errorWithDomain:@""
                                                 code:123
                                             userInfo:nil];
            
            [self.delegate userrequest:self didFailWithError:error];
        }
        
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(userrequest:didFailWithError:)]) {
        [self.delegate userrequest:self didReceiveData:returnData];
    }
    
    return;
}

@end
