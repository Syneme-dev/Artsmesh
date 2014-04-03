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

-(void)getGroupInfo
{
    AMQueryGroupsOperation* queryOper = [[AMQueryGroupsOperation alloc]
                                         initWithParameter: Preference_ArtsmeshIO_IP
                                         serverPort:Preference_ArtsmeshIO_Port
                                         delegate:self];
    
    [[AMMesher sharedEtcdOperQueue] addOperation:queryOper];
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
        for(AMGroup* group in queryOper.usergroups)
        {
            if ([group.name isEqualToString:@"Artsmesh"])
            {
                BOOL isExist = NO;
                for(AMUser* user in _usersFromArtsmeshIO)
                {
                    //
                }
            }
            else
            {
                BOOL isExist = NO;
                for(AMGroup* myGroup in _groupFromArtsmeshIO)
                {
                    if([myGroup.name isEqualToString:group.name])
                    {
                        isExist = YES;
                        NSMutableArray* differentFields = [[NSMutableArray alloc] init];
                        if ([myGroup isEqualToGroup:group differentFields:differentFields])
                        {
                            continue;
                        }
                        else
                        {
                            //updata group in local
                            //add update operation
                            
                        }
                    }
                    
                    if(isExist == NO)
                    {
                        //add group in local
                        //add group operation
                    }
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
