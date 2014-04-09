//
//  AMETCDLANDestination.m
//  AMMesher
//
//  Created by Wei Wang on 4/7/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDLANDestination.h"
#import "AMGroup.h"
#import "AMUser.h"
#import "AMMesher.h"
#import "AMETCDOperationHeader.h"
#import "AMMesherPreference.h"

@implementation AMETCDLANDestination


-(void)handleQueryEtcdFinished:(AMETCDResult*)res source:(AMETCDDataSource*)source
{
//    if(res.errCode != 0 || ![source.name isEqualToString:@"ArtsmeshIO"])
//    {
//        return;
//    }
//    
//    if (res.node.nodes == nil || ![res.node.key isEqualToString:@"/Groups"])
//    {
//        return;
//    }
//    
//    for (AMETCDNode* groupNode in res.node.nodes)
//    {
//        NSArray* pathes = [groupNode.key componentsSeparatedByString:@"/"];
//        if ([pathes count] < 3)
//        {
//            continue;
//        }
//        
//        NSString* groupName = pathes[2];
//    
//        if (![groupName isEqualToString:@"Artsmesh"])
//        {
//            AMGroup* newGroup = [[AMGroup alloc] initWithFullName:groupName];
//            NSMutableDictionary* groupFields = [[NSMutableDictionary alloc] init];
//            for (AMETCDNode* groupPropertyNode in groupNode.nodes)
//            {
//                NSArray* pathes = [groupPropertyNode.key componentsSeparatedByString:@"/"];
//                if ([pathes count] < 4)
//                {
//                    continue;
//                }
//                
//                if (!groupPropertyNode.isDir)
//                {
//                    [newGroup setValue:groupPropertyNode.value forKey:groupPropertyNode.key];
//                    [groupFields setObject:groupPropertyNode.value forKey:groupPropertyNode.key];
//                }
//            }
//            
//            BOOL shouldAdd  = ![[AMMesher sharedAMMesher] containGroup:groupName];
//            if (shouldAdd == YES)
//            {
//                AMETCDAddGroupOperation* addGroupOper = [[AMETCDAddGroupOperation alloc]
//                                                         initWithParameter:self.ip
//                                                         port:self.port
//                                                         fullGroupName:newGroup.fullname
//                                                         ttl:Preference_User_TTL];
//                
//                [[AMMesher sharedEtcdOperQueue] addOperation:addGroupOper];
//            }
//            else
//            {
//                NSDictionary* diffFields = [[AMMesher sharedAMMesher] getGroupChange:newGroup];
//                
//                AMETCDUpdateGroupOperation* updateGroupOper = [[AMETCDUpdateGroupOperation alloc]
//                                                               initWithParameter:self.ip
//                                                               port:self.port
//                                                               fullGroupName:newGroup.fullname
//                                                               groupProperties:diffFields];
//                
//                [[AMMesher sharedEtcdOperQueue] addOperation:updateGroupOper];
//            }
//        }
//        else
//        {
//            for (AMETCDNode* groupPropertyNode in groupNode.nodes)
//            {
//                NSArray* pathes = [groupPropertyNode.key componentsSeparatedByString:@"/"];
//                if ([pathes count] < 4)
//                {
//                    continue;
//                }
//                
//                NSString* propertyName = pathes[3];
//                if (![propertyName isEqualToString:@"Users"])
//                {
//                    continue;
//                }
//    
//                for(AMETCDNode* userNode in groupPropertyNode.nodes)
//                {
//                    NSArray* pathes = [userNode.key componentsSeparatedByString:@"/"];
//                    if ([pathes count] < 5)
//                    {
//                        continue;
//                    }
//                    
//                    NSString* userName = [pathes objectAtIndex:4];
//                    AMUser* newUser = [[AMUser alloc] initWithFullName:userName];
//                    NSMutableDictionary* userFields = [[NSMutableDictionary alloc] init];
//                    for (AMETCDNode* userPropertyNode in userNode.nodes)
//                    {
//                        NSArray* pathes = [userPropertyNode.key componentsSeparatedByString:@"/"];
//                        if ([pathes count] < 6)
//                        {
//                            continue;
//                        }
//                        
//                        NSString* userPropertyName = pathes[5];
//                        NSString* userPropertyVal = userPropertyNode.value;
//                        
//                        [newUser setValue:userPropertyVal forKey:userPropertyName];
//                        [userFields setObject:userPropertyVal forKey:userPropertyName];
//                    }
//                    
//                    BOOL shouldAdd = [[AMMesher sharedAMMesher] containUser:userName inGroup: @"Artsmesh"];
//                    if (shouldAdd == YES)
//                    {
//                        AMETCDAddUserOperation* addUserOper = [[AMETCDAddUserOperation alloc]
//                                                               initWithParameter:self.ip
//                                                               port:self.port
//                                                               fullUserName:newUser.fullname
//                                                               fullGroupName:newUser.groupName
//                                                               ttl:Preference_User_TTL];
//                        
//                        [[AMMesher sharedEtcdOperQueue] addOperation:addUserOper];
//                    }
//                    else
//                    {
//                        NSDictionary* diffFields = [[AMMesher sharedAMMesher] getUserChange:newUser inGroup:groupName];
//                        
//                        AMETCDUpdateUserOperation* updateUserOper = [[AMETCDUpdateUserOperation alloc]
//                                                                     initWithParameter:self.ip
//                                                                     port:self.port
//                                                                     fullUserName:newUser.fullname
//                                                                     fullGroupName:newUser.groupName
//                                                                     userProperties:diffFields];
//                        
//                        [[AMMesher sharedEtcdOperQueue] addOperation:updateUserOper];
//                    }
//                }
//                
//            }
//        }
//    }
    
}



-(void)handleWatchEtcdFinished:(AMETCDResult*)res source:(AMETCDDataSource*)source
{
//    if(res.errCode != 0 || ![source.name isEqualToString:@"ArtsmeshIO"])
//    {
//        return;
//    }
//    
//    NSArray* pathes = [res.key componentsSeparatedByString:@"/"];
//    if ([pathes count] == 3 && [res.action isEqualToString:@"delete"])
//    {
//        NSString* fullGroupName = pathes[2];
//        AMETCDDeleteGroupOperation* deleteGroupOper = [[AMETCDDeleteGroupOperation alloc]
//                                                       initWithParameter:self.ip
//                                                       port:self.port
//                                                       fullGroupName:fullGroupName];
//        
//        [[AMMesher sharedEtcdOperQueue] addOperation:deleteGroupOper];
//        
//        return;
//    }
//    
//    if ([pathes count] == 5 && [res.action isEqualToString:@"delete"])
//    {
//        NSString* fullUserName = pathes[4];
//        NSString* fullGroupName = pathes[2];
//        
//        AMETCDDeleteUserOperation* deleteUserOper = [[AMETCDDeleteUserOperation alloc]
//                                                     initWithParameter:self.ip
//                                                     port:self.port
//                                                     fullUserName:fullUserName fullGroupName:fullGroupName];
//        
//        [[AMMesher sharedEtcdOperQueue] addOperation:deleteUserOper];
//        return;
//    }
//    
//    if ([pathes count] == 4 && [res.action isEqualToString:@"set"])
//    {
//        NSString* fullGroupName = pathes[2];
//        NSString* propertyName = pathes[3];
//        
//        NSMutableDictionary* changeProperty = [[NSMutableDictionary alloc] init];
//        [changeProperty setObject:res.node.value forKey:propertyName];
//        
//        AMETCDUpdateGroupOperation* updateGroupOper = [[AMETCDUpdateGroupOperation alloc]
//                                                       initWithParameter:self.ip
//                                                       port:self.port
//                                                       fullGroupName:fullGroupName
//                                                       groupProperties:changeProperty];
//        
//        [[AMMesher sharedEtcdOperQueue] addOperation:updateGroupOper];
//
//        return;
//    }
//    
//    if ([pathes count] == 6 && [res.action isEqualToString:@"set"])
//    {
//        NSString* fullGroupName = pathes[2];
//        NSString* fullUserName = pathes[4];
//        NSString* userPropertyName = pathes[5];
//        
//        NSMutableDictionary* changeProperty = [[NSMutableDictionary alloc] init];
//        [changeProperty setObject:res.node.value forKey:userPropertyName];
//        
//        AMETCDUpdateUserOperation* updateUserOper = [[AMETCDUpdateUserOperation alloc]
//                                                     initWithParameter:self.ip
//                                                     port:self.port
//                                                     fullUserName:fullUserName
//                                                     fullGroupName:fullGroupName
//                                                     userProperties:changeProperty];
//        
//        [[AMMesher sharedEtcdOperQueue] addOperation:updateUserOper];
//        
//        return;
//    }
//    
//    
//    if ([pathes count] == 3 && [res.action isEqualToString:@"set"])
//    {
//        NSString* fullGroupName = pathes[2];
//        AMETCDAddGroupOperation* addGroupOper = [[AMETCDAddGroupOperation alloc]
//                                                 initWithParameter:self.ip
//                                                 port:self.port
//                                                 fullGroupName:fullGroupName
//                                                 ttl:Preference_User_TTL];
//        
//        [[AMMesher sharedEtcdOperQueue] addOperation:addGroupOper];
//    
//        return;
//    }
//    
//    if ([pathes count] == 5 && [res.action isEqualToString:@"set"])
//    {
//        NSString* fullGroupName = pathes[2];
//        NSString* fullUserName = pathes[4];
//        
//        AMETCDAddUserOperation* addUserOper = [[AMETCDAddUserOperation alloc]
//                                               initWithParameter:self.ip
//                                               port:self.port fullUserName:fullUserName
//                                               fullGroupName:fullGroupName
//                                               ttl:Preference_User_TTL];
//        
//        [[AMMesher sharedEtcdOperQueue] addOperation:addUserOper];
//        
//        return;
//    }
}




@end
