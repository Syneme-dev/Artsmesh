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
@synthesize description;

-(NSMutableDictionary*)dictWithoutUsers
{
    NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
    dict[@"groupId"] = self.groupId;

    if (self.groupName) {
        dict[@"groupName"] = self.groupName;
    }
    
    if (self.description) {
        dict[@"description"] = self.description;
    }
    
    if(self.leaderId){
        dict[@"leaderId"] = self.leaderId;
    }
    
    if (self.fullName){
         dict[@"fullName"] = self.fullName;
    }
    
    
    if (self.project) {
        dict[@"project"] = self.project;
    }
    
    if(self.location){
        dict[@"location"] = self.location;
    }
    
    if (self.longitude) {
        dict[@"longitude"] = self.longitude;
    }
    
    if (self.latitude) {
        dict[@"latitude"] = self.latitude;
    }
    
    if (self.timezoneName) {
        dict[@"timezoneName"] = self.timezoneName;
    }
    
    if (self.homePage){
        dict[@"homepage"] = self.homePage;
    }
   
    if (self.projectDescription) {
        dict[@"projectDesctription"] = self.projectDescription;
    }

    if (self.busy) {
        [dict setObject:@"YES" forKey:@"busy"];
    }else if(self.busy == NO){
        [dict setObject:@"NO" forKey:@"busy"];
    }
    
    if(self.broadcasting){
        [dict setObject:@"YES" forKey:@"broadcasting"];
    }else{
        [dict setObject:@"NO" forKey:@"broadcasting"];
    }
    
    if (self.broadcastingURL) {
        dict[@"broadcastingURL"] = self.broadcastingURL;
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
    group.longitude = dict[@"Longitude"];
    group.latitude = dict[@"Latitude"];
    group.busy = [dict[@"Busy"] boolValue];
    group.timezoneName = dict[@"TimezoneName"];
    group.homePage = dict[@"HomePage"];
    group.projectDescription = dict[@"ProjectDescription"];
    group.password = @"";
    group.broadcasting = [dict[@"Broadcasting"] boolValue];
    group.broadcastingURL = dict[@"BroadcastingURL"];
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
