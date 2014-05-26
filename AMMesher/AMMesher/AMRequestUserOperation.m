//
//  AMRequestUserOperation.m
//  AMMesher
//
//  Created by Wei Wang on 5/26/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMRequestUserOperation.h"
#import "AMMesherOperationDelegate.h"

@implementation AMRequestUserOperation

-(id)initWithMesherServerUrl:(NSString*)mesherServerURL{
    
    if (self = [super init]) {
        self.mesherSeverURL = mesherServerURL;
    }
    
    return self;
}

-(void)main{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:self.mesherSeverURL]];
    [request setHTTPMethod:@"GET"];
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request
                                               returningResponse:nil error:nil];
    NSString* resultLog = [[NSString alloc] initWithData:returnData
                                                encoding:NSUTF8StringEncoding];
    NSLog(@"get user list:%@\n", resultLog);
    

    NSError *jsonParsingError = nil;
    id objects = [NSJSONSerialization JSONObjectWithData:returnData
                                                 options:0
                                                   error:&jsonParsingError];
    if(jsonParsingError != nil){
        self.errorDescription = [NSString stringWithFormat:@"get userlist request failed! %@",
                                 resultLog];
        self.isSucceeded = NO;
        
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(MesherOperDidFinished:) withObject:self waitUntilDone:NO];
        
        return;
    }
    
    if (objects != nil) {
        //parst objects
        
        self.isSucceeded = YES;
        [(NSObject *)self.delegate performSelectorOnMainThread:@selector(MesherOperDidFinished:) withObject:self waitUntilDone:NO];
        
        return;
    }

    [(NSObject *)self.delegate performSelectorOnMainThread:@selector(MesherOperDidFinished:) withObject:self waitUntilDone:NO];

}

@end
