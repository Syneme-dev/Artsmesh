//
//  AMMesherAgent.m
//  AMMesher
//
//  Created by 王 为 on 4/3/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMMesherAgent.h"
#import "AMUserGroupNode.h"
#import "AMUser.h"
#import "AMGroup.h"
#import "AMMesher.h"
#import "AMMesherPreference.h"
#import "AMMesherOperationHeader.h"

@implementation AMMesherAgent
{
    NSMutableArray* _usersFromArtsmeshIO;
    NSMutableArray* _groupFromArtsmeshIO;
    
    NSMutableArray* _usersToArtsmeshIO;
    NSMutableArray* _groupToArtsmeshIO;
    
    NSTimer* _pushTTLTimer;
}


-(id)init
{
    if (self = [super init])
    {
        _usersFromArtsmeshIO = [[NSMutableArray alloc] init];
        _groupFromArtsmeshIO = [[NSMutableArray alloc] init];
        _usersToArtsmeshIO = [[NSMutableArray alloc] init];
        _groupToArtsmeshIO =[[NSMutableArray alloc] init];
    }
    
    return self;
}


-(void)goOnline
{
    [self syncLocalUserGroup];
    [self pushUserGroupCache];
    [self getUserGroupOnline];
    
    
}

-(void)goOffline
{
    [_pushTTLTimer invalidate];
}

-(void)syncLocalUserGroup
{
    @synchronized(self)
    {
        [_groupToArtsmeshIO removeAllObjects];
        [_usersToArtsmeshIO removeAllObjects];
        
        AMMesher* mesher = [AMMesher sharedAMMesher];
        @synchronized(mesher)
        {
            for(AMGroup* group in mesher.userGroups)
            {
                if ([group.name isEqualToString:@"Artsmesh"])
                {
                    for(AMUser* user in group.children)
                    {
                        AMUser* globUser = [user copyUser];
                        globUser.name = [NSString stringWithFormat:@"%@.%@", user.name, user.domain];
                        [_usersToArtsmeshIO addObject:globUser];
                    }
                }
                else
                {
                    AMGroup* globGroup = [group copyWithoutUsers];
                    globGroup.name = [NSString stringWithFormat:@"%@.%@", group.name, group.domain];
                    [_groupToArtsmeshIO addObject:globGroup];
                }
            }
        }
    }
}

-(void)pushUserGroupCache
{
    @synchronized(self)
    {
        for ( AMUser* user in _usersToArtsmeshIO)
        {
            NSDictionary* properties = [user fieldsAndValue];
            
            
            AMAddUserOperation* addOper = [[AMAddUserOperation alloc]
                                           initWithParameter:Preference_ArtsmeshIO_IP
                                           serverPort:Preference_ArtsmeshIO_Port
                                           username:user.name
                                           groupname:user.groupName
                                           userProperties:properties
                                           ttl:Preference_User_TTL
                                           delegate:self];
            
            [[AMMesher sharedEtcdOperQueue] addOperation:addOper];
        }
        
        for( AMGroup* group in _groupToArtsmeshIO)
        {
            NSDictionary* properties = [group fieldsAndValue];
            
            AMAddGroupOperation* addOper = [[AMAddGroupOperation alloc]
                                            initWithParameter:Preference_ArtsmeshIO_IP
                                            serverPort:Preference_ArtsmeshIO_Port
                                            groupname:group.name
                                            groupProperties:properties
                                            ttl:Preference_User_TTL
                                            delegate:self];
            
            [[AMMesher sharedEtcdOperQueue] addOperation:addOper];
        }
    }
    
    _pushTTLTimer = [NSTimer scheduledTimerWithTimeInterval:Preference_User_TTL_Interval
                                                     target:self
                                                   selector:@selector(setUserGroupTTL)
                                                   userInfo:nil repeats:YES];
}

-(void)setUserGroupTTL
{
    @synchronized(self)
    {
        for ( AMUser* user in _usersToArtsmeshIO)
        {
            AMUserTTLOperation* ttlOper = [[AMUserTTLOperation alloc]
                                           initWithParameter:Preference_ArtsmeshIO_IP
                                           serverPort:Preference_ArtsmeshIO_Port
                                           username:user.name
                                           groupname:user.groupName
                                           ttltime:Preference_User_TTL
                                           delegate:self];
            
            [[AMMesher sharedEtcdOperQueue] addOperation:ttlOper];
        }
        
        for( AMGroup* group in _groupToArtsmeshIO)
        {
            AMGroupTTLOperation* ttlOper = [[AMGroupTTLOperation alloc]
                                            initWithParameter:Preference_ArtsmeshIO_IP
                                            serverPort:Preference_ArtsmeshIO_Port
                                            groupname:group.name ttltime:Preference_User_TTL
                                            delegate:self];
            
            [[AMMesher sharedEtcdOperQueue] addOperation:ttlOper];
        }
    }
}

-(void)getUserGroupOnline
{
    AMQueryGroupsOperation* queryOper = [[AMQueryGroupsOperation alloc]
                                         initWithParameter: Preference_ArtsmeshIO_IP
                                         serverPort:Preference_ArtsmeshIO_Port
                                         delegate:self];
    
    [[AMMesher sharedEtcdOperQueue] addOperation:queryOper];
}

-(void)syncOnlineGroup:(NSMutableArray*)onlineGroups
{
    AMMesher* instance = [AMMesher sharedAMMesher];
    
    //delete operation
    for (int i = 0; i < [_groupFromArtsmeshIO count]; i++)
    {
        BOOL shouldBeDelete = YES;
        AMGroup* cacheGroup = [_groupFromArtsmeshIO objectAtIndex:i];
        
        for (AMGroup* onlineGroup in onlineGroups)
        {
            if ([onlineGroup.name isEqualToString:cacheGroup.name])
            {
                shouldBeDelete = NO;
                break;
            }
        }
        
        if (shouldBeDelete)
        {
            [_groupFromArtsmeshIO removeObject:cacheGroup];
        
            
            AMDeleteGroupOperation* delOper = [[AMDeleteGroupOperation alloc]
                                               initWithParameter:instance.myIp
                                               serverPort:[NSString stringWithFormat:@"%d", Preference_ETCDClientPort]
                                               groupname:cacheGroup.name
                                               delegate:self];
            
            [[AMMesher sharedEtcdOperQueue] addOperation:delOper];
        }
    }
    
    //add operation
    for (AMGroup* onlineGroup in onlineGroups)
    {
        BOOL shouldAdd = YES;
        for (int i = 0; i < [_groupFromArtsmeshIO count]; i++)
        {
            AMGroup* cacheGroup = [_groupFromArtsmeshIO objectAtIndex:i];
            if ([cacheGroup.name isEqualToString:onlineGroup.name])
            {
                shouldAdd = NO;
                break;
            }
        }
        
        for (int i = 0; i < [_groupToArtsmeshIO count]; i++)
        {
            AMGroup* cacheGroup = [_groupToArtsmeshIO objectAtIndex:i];
            if ([cacheGroup.name isEqualTo:onlineGroup.name])
                {
                    shouldAdd = NO;
                    break;
                }
        }
        
        if (shouldAdd)
        {
            [_groupFromArtsmeshIO addObject:onlineGroup];
            
            AMAddGroupOperation* addGroupOper = [[AMAddGroupOperation alloc]
                                                 initWithParameter: instance.myIp
                                                 serverPort:[NSString stringWithFormat:@"%d", Preference_ETCDClientPort]
                                                 groupname:onlineGroup.name
                                                 groupProperties:[onlineGroup fieldsAndValue]
                                                 ttl:Preference_User_TTL
                                                 delegate:self];
            
            [[AMMesher sharedEtcdOperQueue] addOperation:addGroupOper];
        }
    }
    
    //update operation
    for (AMGroup* onlineGroup in onlineGroups)
    {
        for (int i = 0; i < [_groupFromArtsmeshIO count]; i++)
        {
            AMGroup* cacheGroup = [_groupFromArtsmeshIO objectAtIndex:i];
            
           
            
            if ([cacheGroup.name isEqualToString:onlineGroup.name])
            {
                NSMutableDictionary* updateProperties = [[NSMutableDictionary alloc] init];
                BOOL isEqual = [cacheGroup isEqualToGroup:onlineGroup differentFields:updateProperties];
                if (!isEqual)
                {
                    AMUpdateGroupOperation* updateOper = [[AMUpdateGroupOperation alloc]
                                                          initWithParameter:instance.myIp
                                                          serverPort:[NSString stringWithFormat:@"%d", Preference_ETCDClientPort]
                                                          groupname:onlineGroup.name
                                                          groupProperties:updateProperties
                                                          delegate:self];
                    
                    [[AMMesher sharedEtcdOperQueue] addOperation:updateOper];
                }
            }
        }
    }
}

-(void)syncOnlineUsers:(NSMutableArray*)onlineUsers
{
    AMMesher* instance = [AMMesher sharedAMMesher];
    
    //delete operation
    for (int i = 0; i < [_usersFromArtsmeshIO count]; i++)
    {
        BOOL shouldBeDelete = YES;
        AMUser* cacheUser = [_usersFromArtsmeshIO objectAtIndex:i];
        
        for (AMUser* onlineUser in onlineUsers)
        {
            if ([onlineUser.name isEqualToString:cacheUser.name])
            {
                shouldBeDelete = NO;
                break;
            }
        }
    
        if (shouldBeDelete)
        {
            [_usersFromArtsmeshIO removeObject:cacheUser];
            
            AMDeleteUserOperation* delOper = [[AMDeleteUserOperation alloc]
                                               initWithParameter:instance.myIp
                                               serverPort:[NSString stringWithFormat:@"%d", Preference_ETCDClientPort]
                                               username:cacheUser.name
                                               groupname:cacheUser.groupName
                                               delegate:self];
            
            [[AMMesher sharedEtcdOperQueue] addOperation:delOper];
        }
    }
    
    //add operation
    for (AMUser* onlineUser in onlineUsers)
    {
        BOOL shouldAdd = YES;
        for (int i = 0; i < [_usersFromArtsmeshIO count]; i++)
        {
            AMUser* cacheUser = [_usersFromArtsmeshIO objectAtIndex:i];
            if ([cacheUser.name isEqualToString:onlineUser.name])
            {
                shouldAdd = NO;
                break;
            }
        }
        
        for (int i = 0; i < [_usersToArtsmeshIO count]; i++)
        {
             AMUser* cacheUser = [_usersToArtsmeshIO objectAtIndex:i];
            if ([cacheUser.name isEqualTo:onlineUser.name])
            {
                shouldAdd = NO;
                break;
            }
        }
        
        if (shouldAdd)
        {
            [_usersFromArtsmeshIO addObject:onlineUser];
            
            AMAddUserOperation* addOper = [[AMAddUserOperation alloc]
                                                initWithParameter:instance.myIp
                                                serverPort:[NSString stringWithFormat:@"%d", Preference_ETCDClientPort]
                                                username:onlineUser.name
                                                groupname:onlineUser.groupName
                                                userProperties:[onlineUser fieldsAndValue]
                                                ttl:Preference_User_TTL
                                                delegate:self];
            
            [[AMMesher sharedEtcdOperQueue] addOperation:addOper];
        }
    }
    
    //update operation
    for (AMUser* onlineUser in onlineUsers)
    {
        for (int i = 0; i < [_usersFromArtsmeshIO count]; i++)
        {
            AMUser* cacheUser = [_usersFromArtsmeshIO objectAtIndex:i];
            if ([cacheUser.name isEqualToString:onlineUser.name])
            {
                NSMutableDictionary* updateProperties = [[NSMutableDictionary alloc] init];
                BOOL isEqual = [cacheUser isEqualToUser: onlineUser differentFields:updateProperties];
                if (!isEqual)
                {
                    AMUpdateUserOperation* updateOper = [[AMUpdateUserOperation alloc]
                                                         initWithParameter:instance.myIp
                                                         serverPort:[NSString stringWithFormat:@"%d", Preference_ETCDClientPort]
                                                         username:onlineUser.name
                                                         groupname:onlineUser.groupName
                                                         changedProperties:updateProperties
                                                         delegate:self];
                    
                    [[AMMesher sharedEtcdOperQueue] addOperation:updateOper];
                }
            }
        }
    }
}


#pragma mark -
#pragma mark AMMesherOperationProtocol
- (void)LanchETCDOperationDidFinish:(NSOperation *)oper
{
    
}

- (void)InitETCDOperationDidFinish:(NSOperation *)oper
{
    
}

- (void)AddGroupOperationDidFinish:(NSOperation*)oper
{
    
}

- (void)DeleteGroupOperationDidFinish:(NSOperation*)oper
{
    
}

- (void)UpdateGroupOperationDidFinish:(NSOperation*)oper
{
    
}

- (void)QueryGroupsOperationDidFinish:(NSOperation *)oper
{
    if (![oper isKindOfClass:[AMQueryGroupsOperation class]])
    {
        return ;
    }
    
    AMQueryGroupsOperation* queryOper = (AMQueryGroupsOperation*)oper;
    if (queryOper.isResultOK)
    {
        @synchronized(self)
        {
            [self syncOnlineGroup:queryOper.usergroups];
            
            for (int i=0; i< [queryOper.usergroups count]; i++)
            {
                AMGroup* group = [queryOper.usergroups objectAtIndex:i];
                if ([group.name isEqualToString:@"Artsmesh"])
                {
                    [self syncOnlineUsers:group.children];
                }
            }
        }
    }
    
}

- (void)AddUserOperationDidFinish:(NSOperation *)oper
{
    
}

- (void)DeleteUserOperationDidFinish:(NSOperation *)oper
{
    
}

- (void)UpdateUserOperationDidFinish:(NSOperation *)oper
{
    
}


@end
