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
    
    if (self.isLeader) {
         [dict setObject:@"YES" forKey:@"isLeader"];
    }else{
        [dict setObject:@"NO" forKey:@"isLeader"];
    }
   
    [dict setObject:self.chatPort forKey:@"chatPort"];
    [dict setObject:self.publicChatPort forKey:@"publicChatPort"];
    
    if (self.isOnline) {
        [dict setObject:@"YES" forKey:@"isOnline"];
    }else{
        [dict setObject:@"NO" forKey:@"isOnline"];
    }
    
    
    return dict;
}

+(id)AMUserFromDict:(NSDictionary*)dict
{
    AMUser* user = [[AMUser alloc] init];
    user.userid = dict[@"UserId"];
    user.nickName = dict[@"NickName"];
    user.domain = dict[@"Domain"];
    user.location = dict[@"Location"];
    user.isLeader = [dict[@"IsLeader"] boolValue];
    user.privateIp = dict[@"PrivateIp"];
    user.publicIp = dict[@"PublicIp"];
    user.chatPort = dict[@"ChatPort"];
    user.publicChatPort = dict[@"PublicChatPort"];
    user.isOnline = [dict[@"IsOnline"] boolValue];
    user.description = dict[@"Description"];
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
    group.groupId = dict[@"GroupId"];
    group.groupName = dict[@"GroupName"];
    group.description = dict[@"Description"];
    group.leaderId = dict[@"LeaderId"];
    group.password = @"";
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


-(BOOL)isMyGroup
{
    AMGroup* localGroup = [AMAppObjects appObjects][AMLocalGroupKey];
    if (localGroup == nil) {
        return NO;
    }
    return [self.groupId isEqualToString:localGroup.groupId];
}


-(BOOL)isMyMergedGroup
{
    NSString* mergedGroupId = [AMAppObjects appObjects][AMMergedGroupIdKey];
    if(mergedGroupId == nil)
        return NO;
    return [mergedGroupId isEqualToString:self.groupId];
}


@end

