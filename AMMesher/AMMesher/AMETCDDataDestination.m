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
#import "AMETCDOperationHeader.h"

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
    
    NSArray* pathes = [res.node.key componentsSeparatedByString:@"/"];
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
                NSString* groupName = [pathes objectAtIndex:2];
                NSArray* groupNameParts = [AMGroup parseFullGroupName:groupName];
                
                NSString* shortName = [groupNameParts objectAtIndex:0];
                NSString* domain = [groupNameParts objectAtIndex:1];
                NSString* location = [groupNameParts objectAtIndex:2];
                
                AMGroup* newGroup = [[AMGroup alloc] initWithName:shortName domain:domain location:location];
                @synchronized(self)
                {
                    [self willChangeValueForKey:@"userGroups"];
                    [self.userGroups addObject:newGroup];
                    [self didChangeValueForKey:@"userGroups"];
                }
                
                return;
            }
            
            if([res.action isEqualToString:@"delete"] || [res.action isEqualToString:@"expire"])
            {
                //delete Group
                NSString* groupName = [pathes objectAtIndex:2];
                @synchronized(self)
                {
                    for(int i = 0; i < [self.userGroups count]; i++)
                    {
                        AMGroup* group = [self.userGroups objectAtIndex:i];
                        if ([group.fullname isEqualToString:groupName])
                        {
                            [self willChangeValueForKey:@"userGroups"];
                            [self.userGroups removeObject:group];
                            [self didChangeValueForKey:@"userGroups"];
                            break;
                        }
                    }
                }
                
                return;
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
                NSString* groupName = [pathes objectAtIndex:2];
                NSString* groupProperyName = [pathes objectAtIndex:3];
                @synchronized(self)
                {
                    for(int i = 0; i < [self.userGroups count]; i++)
                    {
                        AMGroup* group = [self.userGroups objectAtIndex:i];
                        if ([group.fullname isEqualToString:groupName])
                        {
                            [self willChangeValueForKey:@"userGroups"];
                            [group setValue:res.node.value forKey:groupProperyName];
                            [self didChangeValueForKey:@"userGroups"];
                            break;
                        }
                    }
                }
                
                return;
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
                NSString* groupName = [pathes objectAtIndex:2];
                NSString* userName = [pathes objectAtIndex:4];
                
                NSArray* userNameParts = [AMUser parseFullUserName:userName];
                
                NSString* shortName = [userNameParts objectAtIndex:0];
                NSString* domain = [userNameParts objectAtIndex:1];
                NSString* location = [userNameParts objectAtIndex:2];
                
                AMUser* newUser = [[AMUser alloc] initWithName:shortName domain:domain location:location];
                @synchronized(self)
                {
                    for (int i = 0; i < [self.userGroups count]; i++)
                    {
                        AMGroup* group = [self.userGroups objectAtIndex:i];
                        if ([group.fullname isEqualToString:groupName])
                        {
                            [self willChangeValueForKey:@"userGroups"];
                            [group.children addObject:newUser];
                            [self didChangeValueForKey:@"userGroups"];
                        }
                    }
                }
                
                return;
            }
            
            if ([res.action isEqualToString:@"delete"] || [res.action isEqualToString:@"expire"])
            {
                //delete User
                NSString* groupName = [pathes objectAtIndex:2];
                NSString* userName = [pathes objectAtIndex:4];
                
                @synchronized(self)
                {
                    for (int i = 0; i < [self.userGroups count]; i++)
                    {
                        AMGroup* group = [self.userGroups objectAtIndex:i];
                        if ([group.fullname isEqualToString:groupName])
                        {
                            AMGroup* group = [self.userGroups objectAtIndex:i];
                            for (int j = 0 ; j < [group.children count]; j++)
                            {
                                AMUser* user = [group.children objectAtIndex:j];
                                if ([user.fullname isEqualToString:userName])
                                {
                                    [self willChangeValueForKey:@"userGroups"];
                                    [group.children removeObject:user];
                                    [self didChangeValueForKey:@"userGroups"];
                                    break;
                                }
                            }
                            
                            break;
                        }
                    }
                }
                
                return;
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
                NSString* groupName = [pathes objectAtIndex:2];
                NSString* userName = [pathes objectAtIndex:4];
                NSString* userPropertyName = [pathes objectAtIndex:5];
                
                @synchronized(self)
                {
                    for (int i = 0; i < [self.userGroups count]; i++)
                    {
                        AMGroup* group = [self.userGroups objectAtIndex:i];
                        if ([group.fullname isEqualToString:groupName])
                        {
                            AMGroup* group = [self.userGroups objectAtIndex:i];
                            for (int j = 0 ; j < [group.children count]; j++)
                            {
                                AMUser* user = [group.children objectAtIndex:j];
                                if ([user.fullname isEqualToString:userName])
                                {
                                    [self willChangeValueForKey:@"userGroups"];
                                    [user setValue:res.node.value forKey:userPropertyName];
                                    [self didChangeValueForKey:@"userGroups"];
                                    break;
                                }
                            }
                            
                            break;
                        }
                    }
                }
                
                return;
            }
        }
    }
}

#pragma mark -
#pragma mark KVO


-(NSUInteger)countOfGroups
{
    return [self.userGroups count];
}

-(AMUserGroupNode*)objectInGroupsAtIndex:(NSUInteger)index
{
    return [self.userGroups objectAtIndex:index];
}

-(void)addGroupsObject:(AMUserGroupNode *)object
{
    [self willChangeValueForKey:@"userGroups"];
    [self.userGroups addObject:object];
    [self didChangeValueForKey:@"userGroups"];
}

-(void)insertObject:(AMUserGroupNode *)object inGroupsAtIndex:(NSUInteger)index
{
    [self willChangeValueForKey:@"userGroups"];
    [self.userGroups insertObject:object atIndex:index];
    [self didChangeValueForKey:@"userGroups"];
}

-(void)removeObjectFromGroupsAtIndex:(NSUInteger)index
{
    [self willChangeValueForKey:@"userGroups"];
    [self.userGroups removeObjectAtIndex:index];
    [self didChangeValueForKey:@"userGroups"];
}

-(void)removeGroupsObject:(AMUserGroupNode *)object
{
    [self willChangeValueForKey:@"userGroups"];
    [self.userGroups removeObject:object];
    [self didChangeValueForKey:@"userGroups"];
}

-(void)replaceObjectInGroupsAtIndex:(NSUInteger)index withObject:(id)object
{
    [self willChangeValueForKey:@"userGroups"];
    [self.userGroups replaceObjectAtIndex:index withObject:object];
    [self didChangeValueForKey:@"userGroups"];
}



@end
