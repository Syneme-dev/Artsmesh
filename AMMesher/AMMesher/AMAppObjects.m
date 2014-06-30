//
//  AMAppObjects.m
//  AMMesher
//
//  Created by lattesir on 6/15/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMAppObjects.h"
NSString * const AMMeshedGroupKey = @"AMMeshedGroupKey";
NSString * const AMGroupMessageKey = @"AMGroupMessageKey";
NSString * const AMLocalGroupKey = @"AMLocalGroupKey";
NSString * const AMMyselfKey = @"AMMyselfKey";
NSString * const AMMergedGroupIdKey = @"AMMergedGroupIdKey";
NSString * const AMRemoteGroupsKey = @"AMRemoteGroupsKey";
NSString * const AMMesherStateMachineKey = @"AMMesherStateMachineKey";
NSString * const AMSystemConfigKey = @"AMSystemConfigKey";


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
        self.isLeader = NO;
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
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.userid forKey:@"userId"];
    [dict setObject:self.nickName forKey:@"nickName"];
    [dict setObject:self.domain forKey:@"domain"];
    [dict setObject:self.location forKey:@"location"];
    [dict setObject:self.privateIp forKey:@"privateIp"];
    [dict setObject:self.publicIp forKey:@"publicIp"];
    [dict setObject:@(self.isLeader) forKey:@"isLeader"];
    [dict setObject:self.chatPort forKey:@"chatPort"];
    [dict setObject:self.publicChatPort forKey:@"publicChatPort"];
    [dict setObject:@(self.isOnline) forKey:@"isOnline"];
    
    return dict;
}

+(id)AMUserFromDict:(NSDictionary*)dict
{
    AMUser* user = [[AMUser alloc] init];
    user.userid = dict[@"userid"];
    user.nickName = dict[@"nickName"];
    user.domain = dict[@"domain"];
    user.location = dict[@"Location"];
    user.isLeader = [dict[@"localLeader"] boolValue];
    user.privateIp = dict[@"privateIp"];
    user.publicIp = dict[@"publicIp"];
    user.chatPort = dict[@"chatPort"];
    user.publicChatPort = dict[@"publicChatPort"];
    user.isOnline = [dict[@"isOnline"] boolValue];
    user.description = dict[@"description"];
    return user;
}

@end

@implementation AMGroup

-(NSMutableDictionary*)dictWithoutUsers
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    dict[@"groupId"] = self.groupId;
    dict[@"groupName"] = self.groupName;
    dict[@"description"] = self.description;
    dict[@"leaderId"] = self.leaderId;
    return dict;
}

+(id)AMGroupFromDict:(NSDictionary*)dict
{
    AMGroup* group = [[AMGroup alloc] init];
    group.groupId = dict[@"groupId"];
    group.groupName = dict[@"groupName"];
    group.description = dict[@"description"];
    group.leaderId = dict[@"leaderId"];
    return group;
}


-(BOOL)isMeshed
{
    for (AMUser* user in self.users) {
        if (user.isOnline == YES) {
            return YES;
        }
    }
    
    return NO;
}

-(AMUser*)leader
{
    for (AMUser* user in self.users) {
        if ([user.userid isEqualToString:self.leaderId]) {
            return user;
        }
    }

    return nil;
}


@end

