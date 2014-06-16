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

-(void)main{
    if (self.isCancelled) {
        if ([self.delegate respondsToSelector:@selector(userRequestDidCancel)])
            [self.delegate userRequestDidCancel];
        return;
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    NSString* strBaseURL = [self.delegate httpBaseURL];
    NSString* strMethod = [self.delegate httpMethod:self.action];
    
    NSString* strURL= [[NSString alloc] initWithFormat:@"%@%@", strBaseURL, self.action];
    
    [request setURL:[NSURL URLWithString:strURL]];
    [request setHTTPMethod:strMethod];
    
    if ([strMethod isEqualToString:@"POST"]){
        NSString* headerfield = @"application/x-www-form-urlencoded";
        NSMutableDictionary* headerDictionary = [[NSMutableDictionary alloc] init];
        
        [request addValue:headerfield forHTTPHeaderField:@"Content-Type"];
        [request setAllHTTPHeaderFields:headerDictionary];
        
        NSDictionary* bodyDic = [self.delegate httpBody:self.action];
        NSMutableData* httpBody = [self createSetKeyHttpBody:bodyDic];
        [request setHTTPBody: httpBody];
    }
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil error:nil];

    if (self.isCancelled) {
        if ([self.delegate respondsToSelector:@selector(userRequestDidCancel)])
            [self.delegate userRequestDidCancel];
        return;
    }
    
    if (returnData == nil) {
        if ([self.delegate respondsToSelector:@selector(userrequest:didFailWithError:action:)]) {
            
            NSError *error = [NSError errorWithDomain:AMUserRequestDomain
                                                 code:AMUserRequestFalied
                                             userInfo:nil];
            
            [self.delegate userrequest:self didFailWithError:error action:self.action];
        }
        
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(userrequest:didReceiveData:action:)]) {
        [self.delegate userrequest:self didReceiveData:returnData action:self.action];
        
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
