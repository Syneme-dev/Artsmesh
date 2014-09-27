//
//  AMLiveGroup.m
//  AMCoreData
//
//  Created by Wei Wang on 7/17/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMLiveGroup.h"
#import "AMLiveUser.h"

@interface AMLiveGroup()
@end

@implementation AMLiveGroup

-(NSMutableDictionary*)dictWithoutUsers
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    dict[@"groupId"] = self.groupId;
    dict[@"groupName"] = self.groupName;
    dict[@"description"] = self.description;
    dict[@"leaderId"] = self.leaderId;
    dict[@"fullName"] = self.fullName;
    dict[@"project"] = self.project;
    dict[@"location"] = self.location;
    dict[@"longitude"] = self.longitude;
    dict[@"latitude"] = self.latitude;
    
    if (self.busy) {
        [dict setObject:@"YES" forKey:@"busy"];
    }else{
        [dict setObject:@"NO" forKey:@"busy"];
    }
    
    return dict;
}

+(id)AMGroupFromDict:(NSDictionary*)dict
{
    AMLiveGroup* group = [[AMLiveGroup alloc] init];
    group.groupId = dict[@"GroupId"];
    group.groupName = dict[@"GroupName"];
    group.description = dict[@"Description"];
    group.leaderId = dict[@"LeaderId"];
    group.fullName = dict[@"FullName"];
    group.project = dict[@"Project"];
    group.location = dict[@"Location"];
    group.longitude = dict[@"longitude"];
    group.latitude = dict[@"latitude"];
    group.busy = [dict[@"Busy"] boolValue];
    group.password = @"";
    return group;
}


-(BOOL)isMeshed
{
    for (AMLiveUser* user in self.users) {
        if (user.isOnline == YES) {
            return YES;
        }
    }
    
    return NO;
}

-(AMLiveUser*)leader
{
    for (AMLiveUser* user in self.users) {
        if ([user.userid isEqualToString:self.leaderId]) {
            return user;
        }
    }
    
    return nil;
}

-(NSArray*)usersIncludeSubGroup;
{
    return [self getAllUserFromGroup:self];
}


-(NSArray*)getAllUserFromGroup:(AMLiveGroup*)group
{
    NSMutableArray* allUsers = [[NSMutableArray alloc] init];
    [allUsers addObjectsFromArray:group.users];
    
    if (group.subGroups == nil) {
        return allUsers;
    }
    
    for (AMLiveGroup* subg in group.subGroups) {
        [allUsers addObjectsFromArray:[self getAllUserFromGroup:subg]];
    }
    
    return allUsers;
}


@end
