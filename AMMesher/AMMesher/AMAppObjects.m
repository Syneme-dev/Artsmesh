//
//  AMAppObjects.m
//  AMMesher
//
//  Created by lattesir on 6/15/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMAppObjects.h"

NSString * const AMLocaGroupKey = @"AMLocaGroupKey";
NSString * const AMClusterNameKey = @"AMClusterNameKey";
NSString * const AMClusterIdKey = @"AMClusterIdKey";
NSString * const AMLocalUsersKey = @"AMLocalUsersKey";
NSString * const AMMyselfKey = @"AMMyselfKey";
NSString * const AMMergedGroupIdKey = @"AMMergedGroupIdKey";
NSString * const AMRemoteGroupsKey = @"AMRemoteGroupsKey";
NSString * const AMMesherStateMachineKey = @"AMMesherStateMachineKey";
NSString * const AMSystemConfigKey = @"AMSystemConfigKey";
NSString * const AMGroupMessageKey = @"AMGroupMessageKey";
NSString * const AMMeshedGroupsKey = @"AMMeshedGroupsKey";


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
        self.privateIp = @"127.0.0.1";
        self.publicIp = @"127.0.0.1";
        self.localLeader = @"default";
        self.nickName = @"default";
        self.description = @"default";
        self.chatPort = @"9033";
        self.publicChatPort = @"9033";
        self.isOnline = NO;
    }
    
    return self;
}

-(NSMutableDictionary*)toDict
{
    NSMutableDictionary* contentDict = [[NSMutableDictionary alloc] init];
    [contentDict setObject:self.nickName forKey:@"nickName"];
    [contentDict setObject:self.domain forKey:@"domain"];
    [contentDict setObject:self.location forKey:@"location"];
    [contentDict setObject:self.privateIp forKey:@"privateIp"];
    [contentDict setObject:self.publicIp forKey:@"publicIp"];
    [contentDict setObject:self.localLeader forKey:@"localLeader"];
    [contentDict setObject:self.chatPort forKey:@"chatPort"];
    [contentDict setObject:self.publicChatPort forKey:@"publicChatPort"];
    [contentDict setObject:@(self.isOnline) forKey:@"isOnline"];
    
    NSData* userData = [NSJSONSerialization dataWithJSONObject:contentDict options:0 error:nil];
    NSString* userDataStr = [[NSString alloc] initWithData:userData encoding:NSUTF8StringEncoding];
    
    NSMutableDictionary* localHttpBody = [[NSMutableDictionary alloc] init];
    [localHttpBody setObject:userDataStr forKey:@"userData"];
    [localHttpBody setObject:self.userid forKey:@"userId"];
    
    return localHttpBody;
}

+(id)AMUserFromDict:(NSDictionary*)dict
{
    AMUser* tempUser = [[AMUser alloc] init];
    tempUser.userid =[dict objectForKey:@"UserId"];
    NSString* userData = [dict objectForKey:@"UserData"];
    NSData* data = [userData dataUsingEncoding:NSUTF8StringEncoding];
    NSError* err = nil;
    NSDictionary* userObj = [NSJSONSerialization JSONObjectWithData:data
                                                    options:0
                                                      error:&err];
    if (err != nil) {
        NSLog(@"parse json in AMUserFromDict failed!");
        return tempUser;
    }
    
    tempUser.nickName =[userObj objectForKey:@"nickName"];
    tempUser.domain =[userObj objectForKey:@"domain"];
    tempUser.location =[userObj objectForKey:@"Location"];
    tempUser.localLeader =[userObj objectForKey:@"localLeader"];
    tempUser.privateIp =[userObj objectForKey:@"privateIp"];
    tempUser.publicIp =[userObj objectForKey:@"publicIp"];
    tempUser.chatPort =[userObj objectForKey:@"chatPort"];
    tempUser.publicChatPort =[userObj objectForKey:@"publicChatPort"];
    tempUser.isOnline =[[userObj objectForKey:@"isOnline"] boolValue];
    tempUser.description =[userObj objectForKey:@"description"];
    
    return tempUser;
}




@end

