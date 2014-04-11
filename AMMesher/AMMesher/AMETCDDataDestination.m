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

-(void)parseUserNode:(AMETCDNode*)userNode
{
    NSArray* pathes = [userNode.key componentsSeparatedByString:@"/"];
    
    if ([pathes count] < 3)
    {
        return;
    }
    
    if(![[pathes objectAtIndex:1] isEqualToString:@"Users"])
    {
        return;
    }
    
    NSString* uniqueUserName = [pathes objectAtIndex:2];
    NSString* uniqueGroupName = @"Artsmesh";
    
    NSMutableDictionary* otherProps = [[NSMutableDictionary alloc] init];

    
    for (AMETCDNode* userPropNode in userNode.nodes)
    {
        NSArray* userPropPathes = [userPropNode.key componentsSeparatedByString:@"/"];
        if ([userPropPathes count] < 4)
        {
            continue;
        }
        
        NSString* userPropName = [userPropPathes objectAtIndex:3];
        if ([userPropName isEqualToString:@"GroupName"])
        {
            uniqueGroupName  = userPropNode.value;
        }
        else
        {
            [otherProps setObject:userPropNode.value forKey:userPropName];
        }
    }
    
    @synchronized(self)
    {
        [self willChangeValueForKey:@"userGroups"];
        
        BOOL shouldAddGroup= YES;
        AMGroup* userIntoGroup = nil;
        
        for (int i = 0 ; i < [self.userGroups count]; i++)
        {
            AMGroup* existGroup = [self.userGroups objectAtIndex:i];
            if([existGroup.uniqueName isEqualToString:uniqueGroupName])
            {
                shouldAddGroup  = NO;
                userIntoGroup = existGroup;
            }
        }
        
        if (shouldAddGroup == YES)
        {
            userIntoGroup = [[AMGroup alloc] init];
            userIntoGroup.uniqueName = uniqueGroupName;

            [self.userGroups addObject:userIntoGroup];
        }
        
        AMUser* newUser = nil;
        BOOL shouldAddUser = YES;
        for (int i = 0; i < [userIntoGroup countOfChildren]; i++)
        {
            AMUser* existUser = [userIntoGroup.children objectAtIndex:i];
            if ([existUser.uniqueName isEqualToString:uniqueUserName])
            {
                newUser = existUser;
                shouldAddUser = NO;
            }
        }
        if (shouldAddUser)
        {
            newUser = [[AMUser alloc] init];
            newUser.uniqueName = uniqueUserName;
            [userIntoGroup.children addObject:newUser];
        }
        
        for(NSString* key in otherProps)
        {
            NSString* val = [otherProps objectForKey:key];
            [newUser setValue: val forKeyPath:key];
        }

        [self didChangeValueForKey:@"userGroups"];
    }
}


-(void)handleQueryEtcdFinished:(AMETCDResult*)res source:(AMETCDDataSource*)source
{
    if(res.errCode != 0 || ![source.name isEqualToString:@"lanSource"])
    {
        return;
    }
    
    if (res.node.nodes == nil || ![res.node.key isEqualToString:@"/Users"])
    {
        return;
    }
    
    for (AMETCDNode* userNode in res.node.nodes)
    {
        [self parseUserNode:userNode];
    }
}

-(void)handleWatchEtcdFinished:(AMETCDResult *)res source:(AMETCDDataSource *)source
{
    if(res.errCode != 0 || ![source.name isEqualToString:@"lanSource"])
    {
        return;
    }
    
    NSArray* resParts = [res.node.key componentsSeparatedByString:@"/"];
    if([resParts count ] == 3)
    {
        //userOper
        if ([res.action isEqualToString:@"delete"] || [res.action isEqualToString:@"expirated"])
        {
            NSString* uniqueUserName = [resParts objectAtIndex:2];
            @synchronized(self)
            {
                [self willChangeValueForKey:@"userGroups"];
                
                for (int i = 0; i < [self.userGroups count]; i++)
                {
                    AMGroup* existGroup = [self.userGroups objectAtIndex:i];
                    
                    for (int j = 0 ; j < [existGroup countOfChildren]; j++)
                    {
                        AMUser* existUser = [existGroup.children objectAtIndex:j];
                        if ([existUser.uniqueName isEqualToString:uniqueUserName])
                        {
                            [existGroup.children removeObject:existUser];
                            break;
                        }
                    }
                    
                    if ([existGroup countOfChildren] == 0)
                    {
                        [self.userGroups removeObject:existGroup];
                    }
                }
                
                [self didChangeValueForKey:@"userGroups"];
            }
            
            return;
        }
        else
        {
            return;
        }
    }
    
    if ([resParts count] == 4)
    {
        NSString* propName = [resParts objectAtIndex:3];
        NSString* uniqueUserName = [resParts objectAtIndex:2];
        
        if ([propName isEqualToString:@"GroupName"])
        {
            NSString* uniqueGroupName  = res.node.value;
            NSString* prevUniqueGroupName = nil;
            
            if (res.prevNode != nil)
            {
                prevUniqueGroupName = res.prevNode.value;
            }
            
            @synchronized(self)
            {
                [self willChangeValueForKey:@"userGroups"];
                
                BOOL shouldAddGroup = YES;
                
                AMGroup* userIntoGroup = nil;
                AMGroup* userLeaveGroup = nil;
                AMUser* newUser = nil;
                
                for (int i = 0; i < [self.userGroups count]; i++)
                {
                    //find leave group and join group
                    AMGroup* existGroup = [self.userGroups objectAtIndex:i];
                    
                    if ([existGroup.uniqueName isEqualToString:prevUniqueGroupName])
                    {
                        userLeaveGroup = existGroup;
                    }
                
                    else if ([existGroup.uniqueName isEqualToString:uniqueGroupName])
                    {
                        shouldAddGroup = NO;
                        userIntoGroup = existGroup;
                    }
                }
                
                if (userLeaveGroup != nil)
                {
                    //change group
                    for (int j = 0; j < [userLeaveGroup countOfChildren]; j++)
                    {
                        AMUser* existUser = [userLeaveGroup.children objectAtIndex:j];
                        if ([existUser.uniqueName isEqualToString:uniqueUserName])
                        {
                            newUser = existUser;
                            [userLeaveGroup.children removeObject:existUser];
                            break;
                        }
                    }
                    
                    if ([userLeaveGroup countOfChildren] == 0 && ![userLeaveGroup.uniqueName isEqualToString:@"Artsmesh"])
                    {
                        [self.userGroups removeObject:userLeaveGroup];
                    }
                }
            
                if (shouldAddGroup)
                {
                    userIntoGroup = [[AMGroup alloc] init];
                    userIntoGroup.uniqueName = uniqueGroupName;
                    [self.userGroups addObject:userIntoGroup];
                }
                
                BOOL shouldAddUser = YES;
                for (int i = 0; i < [userIntoGroup countOfChildren]; i++)
                {
                    AMUser* existUser = [userIntoGroup.children objectAtIndex:i];
                    if ([existUser.uniqueName isEqualToString:uniqueUserName])
                    {
                        newUser = existUser;
                        shouldAddUser = NO;
                    }
                }
                
                if (newUser == nil)
                {
                    newUser = [[AMUser alloc] init];
                    newUser.uniqueName = uniqueUserName;
                }
                
                if (shouldAddUser)
                {
                    [userIntoGroup.children addObject:newUser];
                }
                
            
                [self didChangeValueForKey:@"userGroups"];
            }
            
            return;
        }
        else
        {
            //don't know how to change
            return;
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
