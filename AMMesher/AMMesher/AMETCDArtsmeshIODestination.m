//
//  AMETCDArtsmeshIODestination.m
//  AMMesher
//
//  Created by Wei Wang on 4/7/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDArtsmeshIODestination.h"
#import "AMGroup.h"
#import "AMUser.h"
#import "AMETCDOperationHeader.h"
#import "AMMesherPreference.h"
#import "AMMesher.h"

@implementation AMETCDArtsmeshIODestination

-(void)parseUserNode:(AMETCDNode*)userNode dependency:(AMETCDOperation*)dependency
{
    NSArray* pathes = [userNode.key componentsSeparatedByString:@"/"];
    if ([pathes count] < 5)
    {
        return;
    }
    
    NSString* fullUserName = [pathes objectAtIndex:4];
    NSString* fullGroupName = [pathes objectAtIndex:2];
    NSArray* userNameParts = [AMUser parseFullUserName:fullUserName];
    
    if ([userNameParts count] < 3)
    {
        return;
    }
    
    NSString* shortUserName = [userNameParts objectAtIndex:0];
    NSString* userDomain = [userNameParts objectAtIndex:1];
    NSString* userLocation = [userNameParts objectAtIndex:2];
    
    if(![userDomain isEqualToString:Preference_MyDomain] || ![userLocation isEqualToString:Preference_MyLocation])
    {
        //don't upload user not belong to my domain'
        return;
    }
    
    AMETCDAddUserOperation* addUserOper = [[AMETCDAddUserOperation alloc]
                                           initWithParameter:self.ip
                                           port:self.port
                                           fullUserName:fullUserName
                                           fullGroupName:fullGroupName
                                           ttl:Preference_MyEtCDUserTTL];
    [addUserOper addDependency:dependency];
    [[AMMesher sharedEtcdOperQueue] addOperation:addUserOper];
    
    
    if (userNode.nodes != nil)
    {
        for (AMETCDNode* userFieldNode in userNode.nodes )
        {
            
            NSArray* pathes = [userFieldNode.key componentsSeparatedByString:@"/"];
            if ([pathes count] < 6)
            {
                continue;
            }
            
            NSString* userPropName = [pathes objectAtIndex:5];
            NSMutableDictionary* properties = [[NSMutableDictionary alloc] init];
            [properties setObject:userFieldNode.value forKey:userPropName];
            
            if (!userFieldNode.isDir)
            {
                AMETCDUpdateUserOperation* updateUserOper = [[AMETCDUpdateUserOperation alloc]
                                                             initWithParameter:self.ip
                                                             port:self.port
                                                             fullUserName:fullUserName
                                                             fullGroupName:fullGroupName
                                                             userProperties:properties];
                if (dependency != nil)
                {
                    [updateUserOper addDependency:addUserOper];
                }
                
                [[AMMesher sharedEtcdOperQueue] addOperation:updateUserOper];
            }
        }
    }
}


-(void)parseGroupNode:(AMETCDNode*) groupNode
{
    NSArray* pathes = [groupNode.key componentsSeparatedByString:@"/"];
    if ([pathes count] < 3)
    {
        return;
    }
    
    NSString* groupName = [pathes objectAtIndex:2];
    
    NSArray* groupNameParts = [AMGroup parseFullGroupName:groupName];
    if ([groupNameParts count] < 3)
    {
        return;
    }
    
    NSString* shortName = [groupNameParts objectAtIndex:0];
    NSString* domain = [groupNameParts objectAtIndex:1];
    NSString* location = [groupNameParts objectAtIndex:2];
    
    if (![domain isEqualToString:Preference_MyDomain] || ![location isEqualToString:Preference_MyLocation])
    {
        //don't upload groups not belong to my domain
        return ;
    }
    
    if (![shortName isEqualToString:@"Artsmesh"])
    {
        //just upload users
        for (AMETCDNode* groupPropertyNode in groupNode.nodes)
        {
            NSArray* pathes = [groupPropertyNode.key componentsSeparatedByString:@"/"];
            if ([pathes count] < 4)
            {
                continue;
            }
            
            if ([[pathes objectAtIndex:3] isEqualToString:@"Users"])
            {
                //add users
                for(AMETCDNode* userNode in groupPropertyNode.nodes)
                {
                    [self parseUserNode:userNode dependency:nil];
                }
            }
        }
    }
    else
    {
        AMETCDAddGroupOperation* addGroupOper = [[AMETCDAddGroupOperation alloc]
                                                 initWithParameter:self.ip
                                                 port:self.port
                                                 fullGroupName:groupName
                                                 ttl:Preference_MyEtCDUserTTL];
        
        [[AMMesher sharedEtcdOperQueue] addOperation:addGroupOper];
    
        for (AMETCDNode* groupPropertyNode in groupNode.nodes)
        {
            NSArray* pathes = [groupPropertyNode.key componentsSeparatedByString:@"/"];
            if ([pathes count] < 4)
            {
                continue;
            }
            
            NSString* groupPropName = [pathes objectAtIndex:3];
            
            if (!groupPropertyNode.isDir)
            {
                //add group property
                NSMutableDictionary* properties = [[NSMutableDictionary alloc] init];
                [properties setObject:groupPropertyNode.value forKey:groupPropName];
                
                AMETCDUpdateGroupOperation* updateGroupOper = [[AMETCDUpdateGroupOperation alloc]
                                                               initWithParameter: self.ip
                                                               port:self.port
                                                               fullGroupName:groupName
                                                               groupProperties:properties];
                [updateGroupOper addDependency:addGroupOper];
                [[AMMesher sharedEtcdOperQueue] addOperation:updateGroupOper];
            }
            
            if ([groupPropName isEqualToString:@"Users"])
            {
                //add users
                for(AMETCDNode* userNode in groupPropertyNode.nodes)
                {
                    [self parseUserNode:userNode dependency:addGroupOper];
                }

            }
        }
    }
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
    
    for (AMETCDNode* groupNode in res.node.nodes)
    {
        [self parseGroupNode:groupNode];
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
            NSString* groupName = [pathes objectAtIndex:2];
            NSArray* groupNameParts = [AMGroup parseFullGroupName:groupName];
            NSString* shortName = [groupNameParts objectAtIndex:0];
            NSString* domain = [groupNameParts objectAtIndex:1];
            NSString* location = [groupNameParts objectAtIndex:2];
            
            if (![domain isEqualToString:Preference_MyDomain] || ![location isEqualToString:Preference_MyLocation])
            {
                return;
            }
            
            //Group Operation
            if ([res.action isEqualToString:@"update"])
            {
                //ttl
                AMETCDGroupTTLOperation* groupTTLOper = [[AMETCDGroupTTLOperation alloc]
                                                         initWithParameter:self.ip
                                                         port:self.port
                                                         fullGroupName:groupName
                                                         ttl:Preference_MyEtCDUserTTL];
                
                [[AMMesher sharedEtcdOperQueue] addOperation:groupTTLOper];
                return;
            }
            
            if ([res.action isEqualToString:@"set"] && res.prevNode == nil)
            {
                //add Group
                AMETCDAddGroupOperation* addGroupOper = [[AMETCDAddGroupOperation alloc]
                                                         initWithParameter:self.ip
                                                         port:self.port
                                                         fullGroupName:groupName
                                                         ttl:Preference_MyEtCDUserTTL];
                
                [[AMMesher sharedEtcdOperQueue] addOperation:addGroupOper];
                
                return;
            }
            
            if([res.action isEqualToString:@"delete"] || [res.action isEqualToString:@"expire"])
            {
                //delete Group
                AMETCDDeleteGroupOperation* deleteGroupOper = [[AMETCDDeleteGroupOperation alloc]
                                                               initWithParameter:self.ip
                                                               port:self.port
                                                               fullGroupName:groupName];
                
                [[AMMesher sharedEtcdOperQueue] addOperation:deleteGroupOper];
        
                return;
            }
        }
    }
    
    if ([pathes count] == 4)
    {
        if ([[pathes objectAtIndex:1] isEqualToString:@"Groups"])
        {
            //Group Operation
            NSString* groupName = [pathes objectAtIndex:2];
            NSArray* groupNameParts = [AMGroup parseFullGroupName:groupName];
            NSString* shortName = [groupNameParts objectAtIndex:0];
            NSString* domain = [groupNameParts objectAtIndex:1];
            NSString* location = [groupNameParts objectAtIndex:2];
            
            if (![domain isEqualToString:Preference_MyDomain] || ![location isEqualToString:Preference_MyLocation])
            {
                return;
            }
            
            if ([res.action isEqualToString:@"set"])
            {
                NSMutableDictionary* properties = [[NSMutableDictionary alloc] init];
                [properties setObject:res.node.value forKey:[pathes objectAtIndex:3]];
                
                //update Group Property
                AMETCDUpdateGroupOperation* updateGroupOper = [[AMETCDUpdateGroupOperation alloc]
                                                               initWithParameter:self.ip
                                                               port:self.port
                                                               fullGroupName:groupName
                                                               groupProperties:properties];
                
                [[AMMesher sharedEtcdOperQueue] addOperation:updateGroupOper];
                
                return;
            }
        }
    }
    
    
    if ([pathes count] == 5)
    {
        if ([[pathes objectAtIndex:3] isEqualToString:@"Users"])
        {
            NSString* groupName = [pathes objectAtIndex:2];
            NSString* userName = [pathes objectAtIndex:4];
            NSArray* userNameParts = [AMUser parseFullUserName:userName];
            NSString* shortName = [userNameParts objectAtIndex:0];
            NSString* domain = [userNameParts objectAtIndex:1];
            NSString* location = [userNameParts objectAtIndex:2];
            
            if (![domain isEqualToString:Preference_MyDomain] || ![location isEqualToString:Preference_MyLocation])
            {
                return;
            }
            
            
            if ([res.action isEqualToString:@"update"])
            {
                //ttl
                AMETCDUserTTLOperation* userTTLOper = [[AMETCDUserTTLOperation alloc]
                                                       initWithParameter:self.ip
                                                       port:self.port
                                                       fullUserName:userName
                                                       fullGroupName:groupName
                                                       ttl:Preference_MyEtCDUserTTL];
                
                [[AMMesher sharedEtcdOperQueue] addOperation:userTTLOper];
                return;
            }
            
            if ([res.action isEqualToString:@"set"] && res.prevNode == nil)
            {
                //add User
                AMETCDAddUserOperation* addUserOper = [[AMETCDAddUserOperation alloc]
                                                       initWithParameter:self.ip
                                                       port:self.port
                                                       fullUserName:userName
                                                       fullGroupName:groupName
                                                       ttl:Preference_MyEtCDUserTTL];
                
                [[AMMesher sharedEtcdOperQueue] addOperation:addUserOper];
                
                return;
            }
            
            if ([res.action isEqualToString:@"delete"] || [res.action isEqualToString:@"expire"])
            {
                //delete User
                AMETCDDeleteUserOperation* deleteUserOper = [[AMETCDDeleteUserOperation alloc]
                                                             initWithParameter:self.ip
                                                             port:self.port
                                                             fullUserName:userName
                                                             fullGroupName:groupName];
                
                [[AMMesher sharedEtcdOperQueue] addOperation:deleteUserOper];
                
                return;
            }
        }
    }
    
    
    if ([pathes count] == 6)
    {
        if ([[pathes objectAtIndex:3] isEqualToString:@"Users"])
        {
            
            NSString* groupName = [pathes objectAtIndex:2];
            NSString* userName = [pathes objectAtIndex:4];
            NSArray* userNameParts = [AMUser parseFullUserName:userName];
            NSString* shortName = [userNameParts objectAtIndex:0];
            NSString* domain = [userNameParts objectAtIndex:1];
            NSString* location = [userNameParts objectAtIndex:2];
            
            if (![domain isEqualToString:Preference_MyDomain] || ![location isEqualToString:Preference_MyLocation])
            {
                return;
            }
            
            
            if ([res.action isEqualToString:@"set"])
            {
                //update User
                NSMutableDictionary* properties = [[NSMutableDictionary alloc] init];
                [properties setObject:res.node.value forKey: [pathes objectAtIndex:5]];
                
                AMETCDUpdateUserOperation* updateUsers = [[AMETCDUpdateUserOperation alloc]
                                                          initWithParameter:self.ip
                                                          port:self.port
                                                          fullUserName:userName
                                                          fullGroupName:groupName
                                                          userProperties:properties];
                
                [[AMMesher sharedEtcdOperQueue] addOperation:updateUsers];
                
                return;
            }
        }
    }

}

@end
