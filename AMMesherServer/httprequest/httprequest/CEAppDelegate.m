//
//  CEAppDelegate.m
//  httprequest
//
//  Created by Wei Wang on 6/13/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "CEAppDelegate.h"
#import <CommonCrypto/CommonDigest.h>

@implementation CEAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    self.rootURL.stringValue = @"http://localhost:8080";

}

-(NSData*)sendHttpRequest:(NSString*)url
                     body:(NSData*)body
                   method:(NSString*)method{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSMutableDictionary* headerDictionary = [[NSMutableDictionary alloc] init];
    NSString* headerfield = @"application/x-www-form-urlencoded";
    
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:method];
    [request addValue:headerfield forHTTPHeaderField:@"Content-Type"];
    [request setAllHTTPHeaderFields:headerDictionary];
    [request setHTTPBody: body];
    
    NSError* error = nil;
    
    NSData *returnData =  [NSURLConnection sendSynchronousRequest:request
                                 returningResponse:nil error:&error];
    return returnData;
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

- (IBAction)actionSelected:(id)sender {
}

- (IBAction)sendRequest:(id)sender {
    
    NSString* url = [NSString stringWithFormat:@"%@%@",  self.rootURL.stringValue, self.operation.stringValue];
    
    NSString* groupId = self.groupId.stringValue;
    NSString* groupName = self.groupName.stringValue;
    NSString* superGroupId = self.superGroupId.stringValue;
    NSString* userId = self.userId.stringValue;
    NSString* userData = self.userData.stringValue;
    
    NSMutableDictionary* bodyDic = [[NSMutableDictionary alloc] init];
    [bodyDic setObject:groupId forKey:@"groupId"];
    [bodyDic setObject:groupName forKey:@"groupData"];
    [bodyDic setObject:superGroupId forKey:@"superGroupId"];
    [bodyDic setObject:userId forKey:@"userId"];
    [bodyDic setObject:userData forKey:@"userData"];
    
    NSMutableData* httpBody = [self createSetKeyHttpBody:bodyDic];
    NSData *returnData = [self sendHttpRequest:url body:httpBody method:@"PUT"];
    NSString* returnStr = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    NSAttributedString* result = [[NSAttributedString alloc] initWithString:returnStr attributes:nil];
    [self.resultView.textStorage appendAttributedString:result];
}

- (IBAction)createGroupId:(id)sender {
    self.groupId.stringValue = [self createUUID];
}

- (IBAction)createUserId:(id)sender {
    self.userId.stringValue = [self createUUID];
}

- (IBAction)clearResult:(id)sender {
   // self.resultView.textStorage
}

- (NSString*) createUUID
{
    // Create universally unique identifier (object)
    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    
    // Get the string representation of CFUUID object.
    NSString *uuidStr = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidObject));
    
    CFRelease(uuidObject);
    
    return uuidStr;
}
@end
