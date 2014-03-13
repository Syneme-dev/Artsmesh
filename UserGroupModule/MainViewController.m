//
//  MainViewController.m
//  UserGroupModule
//
//  Created by xujian on 3/7/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "MainViewController.h"
#import "AMEtcdApi/AMETCD.h"
#import "AMUser.h"

@interface MainViewController ()

@end

@implementation MainViewController
{
    AMUser* _rootUser;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//            
//            AMETCD* etcd = [[AMETCD alloc] init];
//            etcd.clientPort = 4001;
//            
//            NSString* leader = @"";
//            while ([leader isEqualToString: @""]) {
//                leader = [etcd getLeader];
//            }
//            
//            AMETCDResult* res = [etcd listDir:@"/groups" recursive:YES];
//            if(res.errCode == 0)
//            {
//                [self loadGroups: res];
//            }
//            else
//            {
//                [self loadGroups: res];
//                //[self createNewGroups:etcd];
//            }
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.clusterLeader.stringValue = leader;
//                // [self.userGroupTree reloadData];
//                
//            });
//        });
    }
    
    return self;
}

-(void)loadGroups:(AMETCDResult*)res
{
    _rootUser = [[AMUser alloc] init];
    _rootUser.name = @"Groups";
    
    AMUser* group1 = [[AMUser alloc] init];
    group1.name = @"artsmesh";
    
    AMUser* group2 = [[AMUser alloc] init];
    group2.name = @"artsmesh2";
    
    AMUser* user1 = [[AMUser alloc] init];
    user1.name = @"use1";
    AMUser* user2 = [[AMUser alloc] init];
    user2.name = @"use2";
    AMUser* user3 = [[AMUser alloc] init];
    user3.name = @"use3";
    AMUser* user4 = [[AMUser alloc] init];
    user4.name = @"use4";
    
    group1.children = [[NSMutableArray alloc] init];
    group2.children = [[NSMutableArray alloc] init];
    
    [group1.children addObject:user1];
    [group1.children addObject:user2];
    [group2.children addObject:user3];
    [group2.children addObject:user4];
    
    _rootUser.children = [[NSMutableArray alloc] init];
    [_rootUser.children addObject:group1];
    [_rootUser.children addObject:group2];
}

-(void)createNewGroups:(AMETCD*)etcd
{
    [etcd createDir:@"/Groups"];
    [etcd createDir:@"/Groups/Artsmesh"];
}


#pragma mark -
#pragma mark NSOutlineViewDataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    return (item == nil) ? 1 : [item numberOfChildren];
}


- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return (item == nil) ? YES : ([item numberOfChildren] != -1);
}


- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    return (item == nil) ? _rootUser : [(AMUser *)item childAtIndex:index];
}


- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    return (item == nil) ? _rootUser.name : [item name];
}

@end
