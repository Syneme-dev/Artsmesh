//
//  AMUser.m
//  AMMesher
//
//  Created by Wei Wang on 5/25/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMUser.h"
#import <CommonCrypto/CommonDigest.h>

@implementation AMUser

-(id)init{
    
    if(self = [super init]){
        self.userid = [AMUser creatUUID];
        self.groupId = [AMUser creatUUID];;
        self.groupName = @"LocalGroup";
        self.domain = @"Local";
        self.location = @"Local";
        self.publicIp = @"";
        self.privateIp = @"127.0.0.1";
        self.localLeader = @"default";
        self.nickName = @"default";
        self.description = @"default";
        self.chatPort = @"9033";
        self.chatPortMap = @"";
        self.isOnline = NO;
    }
    
    return self;
}

-(NSDictionary*)toLocalHttpBodyDict
{
    NSMutableDictionary* contentDict = [[NSMutableDictionary alloc] init];
    [contentDict setObject:self.nickName forKey:@"nickName"];
    [contentDict setObject:self.domain forKey:@"domain"];
    [contentDict setObject:self.location forKey:@"location"];
    [contentDict setObject:self.privateIp forKey:@"privateIp"];
    [contentDict setObject:self.localLeader forKey:@"localLeader"];
    [contentDict setObject:self.chatPort forKey:@"chatPort"];
    [contentDict setObject:self.chatPortMap forKey:@"chatPortMap"];
    [contentDict setObject:@(self.isOnline) forKey:@"isOnline"];
    
    NSData* userData = [NSJSONSerialization dataWithJSONObject:contentDict options:0 error:nil];
    NSString* userDataStr = [[NSString alloc] initWithData:userData encoding:NSUTF8StringEncoding];
    
    NSMutableDictionary* localHttpBody = [[NSMutableDictionary alloc] init];
    [localHttpBody setObject:userDataStr forKey:@"userData"];
    [localHttpBody setObject:self.userid forKey:@"userId"];
    [localHttpBody setObject:self.groupId forKey:@"groupId"];
    [localHttpBody setObject:self.groupName forKey:@"groupName"];
    
    return localHttpBody;
}

+ (NSString*) creatUUID
{
    // Create universally unique identifier (object)
    CFUUIDRef uuidObject = CFUUIDCreate(kCFAllocatorDefault);
    
    // Get the string representation of CFUUID object.
    NSString *uuidStr = (NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidObject));
    CFRelease(uuidObject);
    
    return uuidStr;
}

@end





