//
//  AMETCDDataDestination.m
//  AMMesher
//
//  Created by 王 为 on 4/9/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDDataDestination.h"
#import "AMGroup.h"
#import "AMUser.h"

@implementation AMETCDDataDestination

-(id)init
{
    if (self = [super init])
    {
        self.userGroups = [[NSMutableArray alloc] init];
    }
    
    return self;
}


-(AMUser*)parseUserNode:(AMETCDNode*)userNode
{
    NSArray* pathes = [userNode.key componentsSeparatedByString:@"/"];
    if ([pathes count] < 5)
    {
        return  nil;
    }
    
    NSString* fullUserName = [pathes objectAtIndex:4];
    NSArray* userNameParts = [AMUser parseFullUserName:fullUserName];
    if ([userNameParts count] < 3)
    {
        return nil;
    }
    NSString* shortUserName = [userNameParts objectAtIndex:0];
    NSString* userDomain = [userNameParts objectAtIndex:1];
    NSString* userLocation = [userNameParts objectAtIndex:2];
    
    AMUser* newUser = [[AMUser alloc] initWithName:shortUserName domain:userDomain location:userLocation];
    
    if (userNode.nodes != nil)
    {
        for (AMETCDNode* userFieldNode in userNode.nodes )
        {
            NSArray* pathes = [userFieldNode.key componentsSeparatedByString:@"/"];
            if ([pathes count] < 6)
            {
                continue;
            }
            
            if (!userFieldNode.isDir)
            {
                [newUser setValue:userFieldNode.value forKey:userFieldNode.key];
            }
        }
    }
    
    return newUser;
}



-(AMGroup*)parseGroupNode:(AMETCDNode*) groupNode
{
    NSArray* pathes = [groupNode.key componentsSeparatedByString:@"/"];
    if ([pathes count] < 3)
    {
        return nil;
    }
    
    NSString* groupName = pathes[2];
    NSArray* groupNameParts = [AMGroup parseFullGroupName:groupName];
    if ([groupNameParts count] < 3)
    {
        return nil;
    }
    
    NSString* shortName = [groupNameParts objectAtIndex:0];
    NSString* domain = [groupNameParts objectAtIndex:1];
    NSString* location = [groupNameParts objectAtIndex:2];
    
    AMGroup* newGroup = [[AMGroup alloc] initWithName:shortName domain:domain location:location];
    for (AMETCDNode* groupPropertyNode in groupNode.nodes)
    {
        NSArray* pathes = [groupPropertyNode.key componentsSeparatedByString:@"/"];
        if ([pathes count] < 4)
        {
            continue;
        }
        
        if (!groupPropertyNode.isDir)
        {
            [newGroup setValue:groupPropertyNode.value forKey:groupPropertyNode.key];
        }
        
        if ([[pathes objectAtIndex:3] isEqualToString:@"Users"])
        {
            NSMutableArray* usersInGroup = [[NSMutableArray alloc] init];
            
            for (AMETCDNode* userNode in groupPropertyNode.nodes)
            {
                AMUser* newUser = [self parseUserNode:userNode];
                
                if (newUser != nil)
                {
                    [usersInGroup addObject:newUser];
                }
            }
        }
    }

    return newGroup;
}



-(void)handleQueryEtcdFinished:(AMETCDResult*)res source:(AMETCDDataSource*)source
{
    if(res.errCode != 0 || ![source.name isEqualToString:@"lanSource"])
    {
        return;
    }
    
    if (res.node.nodes == nil || ![res.node.key isEqualToString:@"/Groups"])
    {
        return;
    }
    
    NSMutableArray* groups = [[NSMutableArray alloc] init];
    for (AMETCDNode* groupNode in res.node.nodes)
    {
        AMGroup* newGroup = [self parseGroupNode: groupNode];
        
        if (newGroup != nil)
        {
            [groups addObject:newGroup  ];
        }
    }
    
    @synchronized(self)
    {
        [self willChangeValueForKey:@"userGroups"];
        self.userGroups = groups;
        [self didChangeValueForKey:@"userGroups"];
    }
}



-(void)handleWatchEtcdFinished:(AMETCDResult*)res source:(AMETCDDataSource*)source
{
    if(res.errCode != 0 || ![source.name isEqualToString:@"lanSource"])
    {
        return;
    }
    
    NSArray* pathes = [res.key componentsSeparatedByString:@"/"];
    if ([pathes count] == 3)
    {
        if ([[pathes objectAtIndex:1] isEqualToString:@"Groups"])
        {
            //Group Operation
            if ([res.action isEqualToString:@"update"])
            {
                //ttl
                return;
            }
            
            if ([res.action isEqualToString:@"set"] && res.prevNode == nil)
            {
                //add Group
            }
            
            if([res.action isEqualToString:@"delete"] || [res.action isEqualToString:@"expire"])
            {
                //delete Group
            }
        }
    }
    
    if ([pathes count] == 4)
    {
        if ([[pathes objectAtIndex:1] isEqualToString:@"Groups"])
        {
            //Group Operation

            if ([res.action isEqualToString:@"set"] && res.prevNode == nil)
            {
                //update Group Property
            }
        }
    }

    
    if ([pathes count] == 5)
    {
        if ([[pathes objectAtIndex:3] isEqualToString:@"Users"])
        {
            if ([res.action isEqualToString:@"update"])
            {
                //ttl
                return;
            }

            if ([res.action isEqualToString:@"set"] && res.prevNode == nil)
            {
                //add User
            }
            
            if ([res.action isEqualToString:@"delete"] || [res.action isEqualToString:@"expire"])
            {
                //delete User
            }
        }
    }

    
    if ([pathes count] == 6)
    {
        if ([[pathes objectAtIndex:3] isEqualToString:@"Users"])
        {
            if ([res.action isEqualToString:@"set"] && res.prevNode != nil)
            {
                //update User
            }
        }
    }
}

@end
