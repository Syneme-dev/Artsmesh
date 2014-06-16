//
//  AMAppObjects.m
//  AMMesher
//
//  Created by lattesir on 6/15/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMAppObjects.h"

NSString * const AMClusterNameKey = @"AMClusterNameKey";
NSString * const AMClusterIdKey = @"AMClusterIdKey";
NSString * const AMLocalUsersKey = @"AMLocalUsersKey";
NSString * const AMMyselfKey = @"AMMyselfKey";
NSString * const AMMergedGroupNameKey = @"AMMergedGroupNameKey";
NSString * const AMRemoteGroupsKey = @"AMRemoteGroupsKey";

static NSMutableDictionary *global_dict = nil;

@implementation AMAppObjects

+ (void)initialize
{
    global_dict = [[NSMutableDictionary alloc] init];
}

+ (NSMutableDictionary*)appObjects
{
    return global_dict;
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


@implementation AMUser

-(id)init{
    
    if(self = [super init]){
        self.userid = [AMAppObjects creatUUID];
        self.domain = @"Local";
        self.location = @"Local";
        self.ip = @"127.0.0.1";
        self.localLeader = @"default";
        self.nickName = @"default";
        self.description = @"default";
        self.chatPort = @"9033";
        self.isOnline = NO;
    }
    
    return self;
}

-(NSMutableDictionary*)toLocalHttpBodyDict
{
    NSMutableDictionary* contentDict = [[NSMutableDictionary alloc] init];
    [contentDict setObject:self.nickName forKey:@"nickName"];
    [contentDict setObject:self.domain forKey:@"domain"];
    [contentDict setObject:self.location forKey:@"location"];
    [contentDict setObject:self.ip forKey:@"ip"];
    [contentDict setObject:self.localLeader forKey:@"localLeader"];
    [contentDict setObject:self.chatPort forKey:@"chatPort"];
    [contentDict setObject:@(self.isOnline) forKey:@"isOnline"];
    
    NSData* userData = [NSJSONSerialization dataWithJSONObject:contentDict options:0 error:nil];
    NSString* userDataStr = [[NSString alloc] initWithData:userData encoding:NSUTF8StringEncoding];
    
    NSMutableDictionary* localHttpBody = [[NSMutableDictionary alloc] init];
    [localHttpBody setObject:userDataStr forKey:@"userData"];
    [localHttpBody setObject:self.userid forKey:@"userId"];
    
    return localHttpBody;
}



@end

