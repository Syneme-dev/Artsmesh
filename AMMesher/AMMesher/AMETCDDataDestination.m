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


-(void)handleWatchEtcdFinished:(AMETCDResult*)res source:(AMETCDDataSource*)source
{
//    if(res.errCode != 0 || ![source.name isEqualToString:@"lanSource"])
//    {
//        return;
//    }
//    
//    NSString* userName = nil;
//    NSString* prevGroupName = nil;
//    NSString* currGroupName = nil;
//    NSMutableDictionary* otherProp = [[NSMutableDictionary alloc] init];
//    
//    NSArray* pathes = [res.node.key componentsSeparatedByString:@"/"];
//    if ([pathes count] == 3)
//    {
//        if ([res.action isEqualToString:@"update"])
//        {
//            //ttl
//            return;
//        }
//        
//        if ([res.action isEqualToString:@"set"] && res.prevNode == nil)
//        {
//            //add User, will not update until group is assigned
//            return;
//        }
//        
//        if([res.action isEqualToString:@"delete"] || [res.action isEqualToString:@"expire"])
//        {
//            //delete user
//            userName = [pathes objectAtIndex:2];
//            
//            @synchronized(self)
//            {
//                [self willChangeValueForKey:@"userGroups"];
//                
//                for(int i = 0; i < [self.userGroups count]; i++)
//                {
//                    AMGroup* existGroup = [self.userGroups objectAtIndex:i];
//                    for(int j = 0; j < [existGroup.children count]; j++)
//                    {
//                        AMUser* existUser = [existGroup.children objectAtIndex:j];
//                        if ([existUser.fullname isEqualToString:userName])
//                        {
//                            [existGroup.children removeObject:existUser];
//                            break;
//                        }
//                    }
//                    
//                    if ([existGroup countOfChildren] == 0 && ![existGroup.fullname isEqualToString:@"Artsmesh"])
//                    {
//                        [self.userGroups removeObject:existGroup];
//                    }
//                }
//                
//                [self didChangeValueForKey:@"userGroups"];
//            }
//        }
//        
//    }
//    else if ([pathes count] == 4)
//    {
//        userName = [pathes objectAtIndex:2];
//        NSString* userChangedPropName = [pathes objectAtIndex:3];
//        
//        if ([userChangedPropName isEqualToString:@"GroupName"])
//        {
//            if ([res.action isEqualToString:@"set"] && res.prevNode == nil)
//            {
//                //add User, will not update until group is assigned
//                return;
//            }
//            else
//            {
//                //join another group
//            }
//        }
//        else
//        {
//            //ordinary prop change
//        }
//    }
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
