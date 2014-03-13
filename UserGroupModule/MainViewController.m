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
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.userGroups = [[NSMutableArray alloc] init];
        
        _artsmeshGroup = [[AMUser alloc]initWithName:@"Artsmesh" isGroup:YES];
        [self.userGroups addObject:_artsmeshGroup];
        
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
   
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.clusterLeader.stringValue = leader;
             });
         });
}

-(void)parseGroupResult:(AMETCDResult*)res
{
    
}

-(void)createDefaultGroup:(AMETCD*)etcd;
{
//    AMUser* artsmeshGroup = [[AMUser alloc] initWithName:@"Artsmesh" isGroup:YES ];
//    [_rootUser.children addObject:artsmeshGroup];
//    [self.userGroupTree reloadData];
}

- (IBAction)createNewGroup:(id)sender {
    NSString* name = [self.createGroupNameField stringValue];
    
   if (![name isEqualToString:@""])
   {
       for (AMUser* group in self.userGroups)
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
    
    long index = self.userGroupTree.selectedRow;
    if(index > 0)
    {
        AMUser* group = [self.userGroups objectAtIndex:index];
        if(group)
        {
            if([group.children count] == 0)
            {
                [self.userGroupTreeController remove:group];
            }
        }
    }
}
@end
