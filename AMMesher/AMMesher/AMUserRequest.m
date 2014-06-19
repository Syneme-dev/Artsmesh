//
//  AMUserRequest.m
//  AMMesher
//
//  Created by Wei Wang on 5/29/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMUserRequest.h"

NSString * const AMUserRequestDomain = @"AMUserRequestDomain";

@implementation AMUserRequest

-(id)init{
    if (self  = [super init]){
        self.httpTimeout = 30;
    }
    
    return self;
}

-(void)main{
    if (self.isCancelled) {
        if ([self.delegate respondsToSelector:@selector(userRequestDidCancel)])
            [self.delegate userRequestDidCancel];
        return;
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString* strBaseURL = [self.delegate httpBaseURL];
    NSString* strURL= [[NSString alloc] initWithFormat:@"%@%@", strBaseURL, self.requestPath];
    
    [request setURL:[NSURL URLWithString:strURL]];
    [request setHTTPMethod:self.httpMethod];
    [request setTimeoutInterval:self.httpTimeout];
    
    if ([self.httpMethod isEqualToString:@"POST"]){
        NSString* headerfield = @"application/x-www-form-urlencoded";
        NSMutableDictionary* headerDictionary = [[NSMutableDictionary alloc] init];
        
        [request addValue:headerfield forHTTPHeaderField:@"Content-Type"];
        [request setAllHTTPHeaderFields:headerDictionary];
        
        NSMutableData* bodyData = [self createSetKeyHttpBody:self.formData];
        [request setHTTPBody: bodyData];
    }
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil error:nil];

    if (self.isCancelled) {
        if ([self.delegate respondsToSelector:@selector(userRequestDidCancel)])
            [self.delegate userRequestDidCancel];
        return;
    }
    
    if (returnData == nil) {
        if ([self.delegate respondsToSelector:@selector(userrequest:didFailWithError:)]) {
            
            NSError *error = [NSError errorWithDomain:AMUserRequestDomain
                                                 code:AMUserRequestFalied
                                             userInfo:nil];
        
            [self.delegate userrequest:self didFailWithError:error];
        }
        
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(userrequest:didReceiveData:)]) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate userrequest:self didReceiveData:returnData];
        });
    }
    
    return;
}


-(NSMutableData*)createSetKeyHttpBody: (NSDictionary*) keyVals
{
    NSMutableData* body = [NSMutableData data];
    for (NSString* k in keyVals)
    {
        if([body length] > 0)
        {
            [body appendData:[@"&" dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        NSString* v = [keyVals objectForKey:k];
        NSString* key = [k stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        key = [key stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
        key = [key stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        
        NSString* val = [v stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        val = [val stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
        val = [val stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        
        [body appendData:[[NSString stringWithFormat:@"%@=%@", key, val] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    return body;
}


@end
