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

@interface MainViewController ()

@end

@implementation MainViewController
{
    AMUser* _artsmeshGroup;
    AMUser* _currentUser;
    AMETCD* _etcd;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.groups = [[NSMutableArray alloc] init];
        _currentUser = nil;
        _etcd  = [[AMETCD alloc] init];
    
        [self loadGroups];
    }
    
    return self;
}

-(void)loadGroups
{
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
   
             NSString* leader = @"";
             while ([leader isEqualToString: @""]) {
                 leader = [_etcd getLeader];
             }
             
             [self createDefaultGroup:_etcd];
   
             AMETCDResult* res = [_etcd listDir:@"/Groups" recursive:YES];
             if(res.errCode == 0)
             {
                 [self parseGroupResult: res];
             }
             else
             {
                 [NSException raise:@"etcd error!" format:@"can not create groups in etcd!"];
             }
             
             int actIndex = 0;
             res = [_etcd watchDir:@"/Groups" fromIndex:2 acturalIndex:&actIndex timeout:0];
             
             while (1) {
                 res = [_etcd watchDir:@"/Groups" fromIndex:actIndex+1 acturalIndex:&actIndex timeout:0];
             }
         });
}

-(void)parseGroupResult:(AMETCDResult*)res
{
    if ([res.node.key isEqualToString:@"/Groups"])
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
    [etcd createDir:@"/Groups"];
    [etcd createDir:@"/Groups/Artsmesh"];
//    
//    _artsmeshGroup = [[AMUser alloc]initWithName:@"Artsmesh" isGroup:YES];
//    [self.groups addObject:_artsmeshGroup];
}

- (IBAction)createNewGroup:(id)sender {
    NSString* name = [self.createGroupNameField stringValue];
    
   if (![name isEqualToString:@""])
   {
       for (AMUser* group in self.groups)
       {
           if ( [group.name isEqualToString:name ] ) {
               return;
           }
       }
       
       AMUser* newUser = [[AMUser alloc]initWithName:name isGroup:YES];
       
       NSUInteger indexes[1];
       indexes[0] = [self.groups count];
       NSIndexPath* indexPath = [[NSIndexPath alloc] initWithIndexes:indexes length:1];

       [self.userGroupTreeController insertObject:newUser atArrangedObjectIndexPath:indexPath];
       
       
     //  [self.userGroupTreeController addObject:newUser];
       [self.createGroupNameField setStringValue:@""];

   }
}

- (IBAction)deleteGroup:(id)sender {
    if([self.groups count] == 1)
    {
        return;
    }
    
    id selectedItem = [self.userGroupTreeView itemAtRow:[self.userGroupTreeView selectedRow]];

    if(selectedItem && [self validateGroupNode:selectedItem])
    {
        [self.userGroupTreeController remove:selectedItem];
    }
    
}

- (IBAction)setUserName:(id)sender {
    NSString* name = [sender stringValue];
    
//    if (![name isEqualToString:@""] && ![name isEqualToString:_myName])
//    {
//        if([self validateUserName:name])
//        {
//            AMUser* me = [[AMUser alloc] initWithName:name isGroup:NO];
//            
//            NSUInteger indexes[2];
//            indexes[0]= 0;
//            indexes[1] = 0;
//            
//            NSIndexPath* indexPath = [[NSIndexPath alloc] initWithIndexes:indexes length:2];
//            if (_myName != nil)
//            {
//                [self.userGroupTreeController removeObjectAtArrangedObjectIndexPath:indexPath];
//            }
//            
//            [self.userGroupTreeController insertObject:me atArrangedObjectIndexPath:indexPath];
//            
//            _myName = name;
//        }
//    }
}

-(BOOL)validateUserName:(NSString*)name
{
    if([self.groups count] != 0)
    {
        AMUser* artmeshGroup = [self.groups objectAtIndex:0];
        
        for(AMUser* user in artmeshGroup.children)
        {
            if([user.name isEqualToString:name])
            {
                return NO;
            }
        }
        
        return YES;
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

@end
