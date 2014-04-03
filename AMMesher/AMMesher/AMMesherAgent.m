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

@implementation AMMesherAgent
{
    NSMutableArray* _usersFromArtsmeshIO;
    NSMutableArray* _groupFromArtsmeshIO;
    NSTimer* _uploadInfoTimer;
}


-(id)init
{
    if (self = [super init])
    {
        _usersFromArtsmeshIO = [[NSMutableArray alloc] init];
        _groupFromArtsmeshIO = [[NSMutableArray alloc] init];
    }
    
    return self;
}


-(void)goOnline
{
   _uploadInfoTimer = [NSTimer scheduledTimerWithTimeInterval:Preference_User_TTL_Interval
                                                       target:self selector:@selector(uploadGroupInfo) userInfo:nil repeats:YES];
}

-(void)goOffline
{
    [_uploadInfoTimer invalidate];
}

-(void)uploadGroupInfo
{
    NSArray* groups = [[AMMesher sharedAMMesher] userGroups];
    
    for(AMGroup* group in groups)
    {
        if ([group.name isEqualToString:@"Artsmesh"])
        {
            //upload every user
            for(AMUser* user in group.children)
            {
            
            }
        }
        else
        {
            //upload GroupName
        }
    }
}

@end
