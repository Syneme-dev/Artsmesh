//
//  AMHttpSyncRequest.m
//  AMMesher
//
//  Created by 王 为 on 6/30/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMHttpSyncRequest.h"
#import "NSData+Base64.h"

@implementation AMHttpSyncRequest

-(id)init{
    if (self  = [super init]){
        self.httpTimeout = 30;
    }
    
    return self;
}

-(NSData*)sendRequest{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString* strURL= [[NSString alloc] initWithFormat:@"%@%@", self.baseURL, self.requestPath];
    
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
    
    if(self.username != nil && self.password != nil){
        NSString *authStr = [NSString stringWithFormat:@"%@:%@", self.username, self.password];
        NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
        NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedString]];
        [request setValue:authValue forHTTPHeaderField:@"Authorization"];
    }
    
    return [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil error:nil];

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
