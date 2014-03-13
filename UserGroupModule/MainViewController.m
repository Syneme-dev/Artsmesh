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
    NSString* _myName;
    
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.groups = [[NSMutableArray alloc] init];
        
        _artsmeshGroup = [[AMUser alloc]initWithName:@"Artsmesh" isGroup:YES];
        [self.groups addObject:_artsmeshGroup];
        
        [self loadGroups];
    }
    
    return self;
}

-(void)loadGroups
{
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
   
             AMETCD* etcd = [[AMETCD alloc] init];
             etcd.clientPort = 4001;
   
             NSString* leader = @"";
             while ([leader isEqualToString: @""]) {
                 leader = [etcd getLeader];
             }
   
             AMETCDResult* res = [etcd listDir:@"/groups" recursive:YES];
             if(res.errCode == 0)
             {
                 [self parseGroupResult: res];
             }
             else
             {
                 [self createDefaultGroup:etcd];
             }
             
             int actIndex = 0;
             res = [etcd watchDir:@"/Groups" fromIndex:2 acturalIndex:&actIndex timeout:0];
             
             while (1) {
                 res = [etcd watchDir:@"/Groups" fromIndex:actIndex+1 acturalIndex:&actIndex timeout:0];
             }
             
             
         });
}

-(void)parseGroupResult:(AMETCDResult*)res
{
    
}

-(void)createDefaultGroup:(AMETCD*)etcd;
{
    [etcd createDir:@"/Groups"];
    [etcd createDir:@"/Groups/Artsmesh"];
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
       [self.userGroupTreeController addObject:newUser];
       [self.createGroupNameField setStringValue:@""];

   }
}

- (IBAction)deleteGroup:(id)sender {
    
    id selectedItem = [self.userGroupTreeView itemAtRow:[self.userGroupTreeView selectedRow]];

    if(selectedItem && [self validateGroupNode:selectedItem])
    {
        [self.userGroupTreeController remove:selectedItem];
    }
    
}

- (IBAction)setUserName:(id)sender {
    NSString* name = [sender stringValue];
    
    if (![name isEqualToString:@""] && ![name isEqualToString:_myName])
    {
        if([self validateUserName:name])
        {
            AMUser* me = [[AMUser alloc] initWithName:name isGroup:NO];
            
            NSUInteger indexes[2];
            indexes[0]= 0;
            indexes[1] = 0;
            
            NSIndexPath* indexPath = [[NSIndexPath alloc] initWithIndexes:indexes length:2];
            if (_myName != nil)
            {
                [self.userGroupTreeController removeObjectAtArrangedObjectIndexPath:indexPath];
            }
            
            [self.userGroupTreeController insertObject:me atArrangedObjectIndexPath:indexPath];
            
            _myName = name;
        }
    }
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
    return [(AMUser*)node isLeaf];
}

@end
