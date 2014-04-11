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
    
//
    
    
    
    
   }


@end
