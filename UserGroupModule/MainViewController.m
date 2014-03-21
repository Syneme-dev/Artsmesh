//
//  MainViewController.m
//  UserGroupModule
//
//  Created by xujian on 3/7/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "MainViewController.h"
#import "AMUser.h"
#import "AMEtcdApi/AMETCD.h"
#import "AMUserGroupServer.h"

#define ROOT_KEY @"/Groups"
#define DEFAULT_GROUP @"Artsmesh"

@interface MainViewController ()

@end

@implementation MainViewController
{
    AMUser* _artsmeshGroup;
    AMUser* _currentUser;
    AMETCD* _etcd;
    BOOL _listeningEtcd;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.groups = [[NSMutableArray alloc] init];
        _currentUser = nil;
        _etcd  = [[AMETCD alloc] init];
        _listeningEtcd = YES;
    
        [self loadGroups];
    }
    
    return self;
}

-(void)StopEverything
{
     _listeningEtcd = NO;
    
    if(_currentUser)
    {
        NSString* userKeyPath = [NSString stringWithFormat:@"%@/%@%/@", ROOT_KEY, _currentUser.parent.name, _currentUser.name];
        [_etcd deleteKey:userKeyPath];
    }
}

-(void)loadGroups
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString* leader = @"";
        while ([leader isEqualToString: @""]) {
            leader = [_etcd getLeader];
        }
        
        [self createDefaultGroup:_etcd];
        
        AMETCDResult* res = [_etcd listDir:ROOT_KEY recursive:YES];
        if(res.errCode == 0)
        {
            [self parseGroupResult: res];
        }
        
        //this must return right now because we have set etcd before
        int actIndex = 0;
        res = [_etcd watchDir:ROOT_KEY fromIndex:2 acturalIndex:&actIndex timeout:0];
        
        while (_listeningEtcd) {
            res = [_etcd watchDir:ROOT_KEY fromIndex:actIndex+1 acturalIndex:&actIndex timeout:0];
            if(res.errCode == 0)
            {
                NSString* action = res.action;
                NSArray* names = [res.node.key pathComponents];
                NSString* groupName = [names objectAtIndex:2];
                NSString* userName = nil;
                if([names count] >= 4 )
                {
                    userName = [names objectAtIndex:3];
                }
                
                //There are 4 situations: group+new group+delete
                //user+new, user+delete,
                if(userName == nil)//group
                {
                    AMUser* group = [self groupByName:groupName];
                    
                    if([action isEqualToString:@"delete"]) //group + delete
                    {
                        if(group != nil)
                        {
                            [self removeGroupsObject:group];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.userGroupTreeView reloadData];
                            });
                        }
                    }
                    else //group+add
                    {
                        if(group == nil)
                        {
                            AMUser* newGroup = [[AMUser alloc] initWithName:groupName isGroup:YES];
                            [self addGroupsObject:newGroup];
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.userGroupTreeView reloadData];
                            });
                        }
                    }
                }
                else //user
                {
                    AMUser* group = [self groupByName:groupName];
                    if([action isEqualToString:@"delete"])//user + delete
                    {
                        if (group != nil)
                        {
                            AMUser* user = [self userByName:userName inGroup:group];
                            if(user != nil)
                            {
                                [group removeChildrenObject:user];
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self.userGroupTreeView reloadData];
                                });
                            }
                        }
                    }
                    else //user+ add
                    {
                        if(group != nil)
                        {
                            AMUser* user = [self userByName:userName inGroup:group];
                            if(user == nil)
                            {
                                AMUser* newUser = [[AMUser alloc] initWithName:userName isGroup:NO];
                                [group addChildrenObject:newUser];
                                
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [self.userGroupTreeView reloadData];
                                });
                            }
                        }
                    }
                }
            }
        }
    });
}


-(AMUser*)userByName:(NSString*)uname inGroup:(AMUser*)group
{
    for (AMUser* u in group.children)
    {
        if([uname isEqualToString:u.name])
        {
            return u;
        }
    }
    
    return nil;
}

-(AMUser*)groupByName:(NSString*)gname
{
    for (int i = 0; i < [self.groups count]; i++)
    {
        AMUser* group = [self objectInGroupsAtIndex:i];
        if ([gname isEqualToString:group.name])
        {
            return group;
        }
    }
    
    return nil;
}


-(void)parseGroupResult:(AMETCDResult*)res
{
    if ([res.node.key isEqualToString:ROOT_KEY])
    {
        //every one in res.node.nodes is a group
        for(AMETCDNode* groupNode in res.node.nodes)
        {
            if(groupNode.isDir)
            {
                NSString* groupName = [groupNode.key lastPathComponent];
                
                AMUser* group = [[AMUser alloc] initWithName:groupName isGroup:YES];
                [self addGroupsObject:group];
                
                for (AMETCDNode* userNode in groupNode.nodes)
                {
                    NSString* userName = [userNode.key lastPathComponent];
                    AMUser* user = [[AMUser alloc] initWithName:userName isGroup:NO];
                    user.parent = group;
                    [group addChildrenObject:user];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.userGroupTreeView reloadData];
        });
    }
}

-(void)createDefaultGroup:(AMETCD*)etcd;
{
    [etcd createDir:ROOT_KEY];
    [etcd createDir: [NSString stringWithFormat:@"%@/%@", ROOT_KEY, DEFAULT_GROUP]];
}

- (IBAction)createNewGroup:(id)sender
{
    NSString* newGroupName = [self.createGroupNameField stringValue];
    
    if ([newGroupName isEqualToString:@""])
    {
        return;
    }
    
//    if(_currentUser == nil)
//    {
//        //must set user name first
//        return;
//    }
    
    for (AMUser* group in self.groups)
    {
        if ( [group.name isEqualToString:newGroupName ] )
        {
            return;
        }
    }
    
    NSString* newGroupKeyPath = [NSString stringWithFormat:@"%@/%@", ROOT_KEY, newGroupName ];
   [_etcd createDir:newGroupKeyPath];

}

- (IBAction)deleteGroup:(id)sender {
    if([self.groups count] == 1)
    {
        return;
    }
    
    id selectedItem = [self.userGroupTreeView itemAtRow:[self.userGroupTreeView selectedRow]];
    
    if(selectedItem && [self validateGroupNode:selectedItem])
    {
        NSTreeNode* node = selectedItem;
        AMUser* delgroup = node.representedObject;
        
        if([delgroup.name isEqualToString:DEFAULT_GROUP])
        {
            //artsmesh group can not be deleted.
            return;
        }
        
        NSString* delGroupKeyPath = [NSString stringWithFormat:@"%@/%@", ROOT_KEY, delgroup.name ];
        [_etcd deleteDir:delGroupKeyPath recursive:NO];
    }
    
}

- (IBAction)setUserName:(id)sender {
    
    NSString* newName = [sender stringValue];
    if([newName isEqualToString:@""])
    {
        return;
    }
    
    if(_currentUser == nil)
    {
        //first time set user name, add to Artsmesh
        if([self validateUserName:newName inGroup:DEFAULT_GROUP])
        {
            NSString* userKey = [NSString stringWithFormat:@"%@/%@/%@",
                                 ROOT_KEY,
                                 [self objectInGroupsAtIndex:0].name,
                                 newName];
            
            //for now value is the same with the key, later will be useful
            AMETCDResult* res = [_etcd setKey:userKey withValue:newName];
            if (res.errCode == 0)
            {
                _currentUser  = [[AMUser alloc] initWithName:newName isGroup:NO];
                _currentUser.parent = [self objectInGroupsAtIndex:0];
            }
            else
            {
                //TODO: notify set falied!
            }
        }
        
        return;
    }
    else
    {
        if([newName isEqualToString:_currentUser.name])
        {
            return;
        }
        
        NSString* userOldKey = [NSString stringWithFormat:@"%@/%@/%@",
                                ROOT_KEY,
                                _currentUser.parent.name,
                                _currentUser.name];
        NSString* userNewKey = [NSString stringWithFormat:@"%@/%@/%@",
                                ROOT_KEY,
                                _currentUser.parent.name,
                                newName];
        
        AMETCDResult* res = [_etcd deleteKey:userOldKey];
        res = [_etcd setKey:userNewKey withValue:userNewKey];
        if (res.errCode == 0)
        {
            _currentUser.name = newName;
        }
        else
        {
            //TODO: notify set falied!
        }
    }
}

- (IBAction)joinGroup:(id)sender
{
    long index = [self.userGroupTreeView selectedRow];
    if (index == -1)
    {
        return;
    }
    
    if( _currentUser == nil)
    {
        return;
    }
    
    id selectedItem = [self.userGroupTreeView itemAtRow:index];
    
    if(selectedItem && [self validateGroupNode:selectedItem])
    {
        NSTreeNode* node = selectedItem;
        AMUser* joinGroup = node.representedObject;
        AMUser* curGroup = _currentUser.parent;
        
        if([curGroup.name isEqualToString:joinGroup.name])
        {
            return;
        }
        
        NSString* removePath = [NSString stringWithFormat:@"%@/%@/%@", ROOT_KEY, curGroup.name, _currentUser.name ];
        NSString* addPath = [NSString stringWithFormat:@"%@/%@/%@", ROOT_KEY, joinGroup.name, _currentUser.name];
        
        AMETCDResult* res = [_etcd deleteKey:removePath];
        if(res.errCode == 0)
        {
            [_etcd setKey:addPath withValue:addPath];
        }
        else
        {
          //TODO:error
        }
    }
}


-(BOOL)validateUserName:(NSString*)name inGroup:(NSString*)groupName
{
    //check if there already the same user name in the group
    if([self.groups count] == 0)
    {
        return NO;
    }
    
    for (AMUser* group in self.groups)
    {
        if([groupName isEqualToString:group.name])
        {
            for(AMUser* user in group.children)
            {
                if([user.name isEqualToString:name])
                {
                    return NO;
                }
            }
            
            return YES;
        }
    }
    
    return NO;
}

-(BOOL)validateGroupNode:(id)node
{
    return ![(AMUser*)node isLeaf];
}



#pragma mark -
#pragma mark KVO

-(NSUInteger)countOfGroups
{
    return [self.groups count];
}

-(AMUser*)objectInGroupsAtIndex:(NSUInteger)index
{
    return [self.groups objectAtIndex:index];
}

-(void)addGroupsObject:(AMUser *)object
{
    [self willChangeValueForKey:@"groups"];
    [self.groups addObject:object];
    [self didChangeValueForKey:@"groups"];
}

-(void)replaceObjectInGroupsAtIndex:(NSUInteger)index withObject:(id)object
{
    [self willChangeValueForKey:@"groups"];
    [self.groups replaceObjectAtIndex:index withObject:object ];
    [self didChangeValueForKey:@"groups"];
}

-(void)insertObject:(AMUser *)object inGroupsAtIndex:(NSUInteger)index
{
    [self willChangeValueForKey:@"groups"];
    [self.groups insertObject:object atIndex:index];
    [self didChangeValueForKey:@"groups"];
}

-(void)removeObjectFromGroupsAtIndex:(NSUInteger)index
{
    [self willChangeValueForKey:@"groups"];
    [self.groups removeObjectAtIndex:index];
    [self didChangeValueForKey:@"groups"];
}

-(void)removeGroupsObject:(AMUser *)object
{
    [self willChangeValueForKey:@"groups"];
    [self.groups removeObject:object];
    [self didChangeValueForKey:@"groups"];
}

@end
