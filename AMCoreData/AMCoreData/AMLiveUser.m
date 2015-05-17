//
//  AMLiveUser.m
//  AMCoreData
//
//  Created by Wei Wang on 7/17/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMLiveUser.h"
#import "AMCommonTools/AMCommonTools.h"

@implementation AMLiveUser
@synthesize description;

-(id)init{
    
    if(self = [super init]){
        self.userid = [AMCommonTools creatUUID];
        self.domain = @"Local";
        self.fullName = @"FullName";
        self.location = @"Local";
        self.privateIp = @"127.0.0.1";
        self.ipv6Address = @"";
        self.publicIp = @"127.0.0.1";
        self.isLeader = NO;
        self.nickName = @"default";
        self.description = @"default";
        self.chatPort = @"9033";
        self.publicChatPort = @"9033";
        self.isOnline = NO;
        self.oscServer = NO;
    }
    
    return self;
}


-(NSMutableDictionary*)toDict
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    [dict setObject:self.userid forKey:@"userId"];
    [dict setObject:self.fullName forKey:@"fullName"];
    [dict setObject:self.nickName forKey:@"nickName"];
    [dict setObject:self.domain forKey:@"domain"];
    [dict setObject:self.location forKey:@"location"];
    [dict setObject:self.privateIp forKey:@"privateIp"];
    [dict setObject:self.ipv6Address forKey:@"ipv6Address"];
    [dict setObject:self.publicIp forKey:@"publicIp"];
    [dict setObject:self.description forKey:@"description"];
    
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
    
    if (self.busy) {
        [dict setObject:@"YES" forKey:@"busy"];
    }else{
        [dict setObject:@"NO" forKey:@"busy"];
    }
    
    if (self.oscServer){
        [dict setObject:@"YES" forKey:@"oscServer"];
    }else{
        [dict setObject:@"NO" forKey:@"oscServer"];
    }
    
    if (self.isIPV6){
        [dict setObject:@"YES" forKey:@"isIPV6"];
    }else{
        [dict setObject:@"NO" forKey:@"isIPV6"];
    }
    
    return dict;
}

+(id)AMUserFromDict:(NSDictionary*)dict
{
    AMLiveUser* user = [[AMLiveUser alloc] init];
    user.userid = dict[@"UserId"];
    user.nickName = dict[@"NickName"];
    user.fullName = dict[@"FullName"];
    user.domain = dict[@"Domain"];
    user.location = dict[@"Location"];
    user.isLeader = [dict[@"IsLeader"] boolValue];
    user.privateIp = dict[@"PrivateIp"];
    user.privateIp = dict[@"Ipv6Address"];
    user.publicIp = dict[@"PublicIp"];
    user.chatPort = dict[@"ChatPort"];
    user.publicChatPort = dict[@"PublicChatPort"];
    user.isOnline = [dict[@"IsOnline"] boolValue];
    user.description = dict[@"Description"];
    user.busy = [dict[@"Busy"] boolValue];
    user.oscServer = [dict[@"OSCServer"] boolValue];
    user.isIPV6= [dict[@"isIPV6"] boolValue];
    return user;
}


@end
