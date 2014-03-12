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


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
           
            AMETCD* etcd = [[AMETCD alloc] init];
            etcd.clientPort = 4001;

            NSString* leader = @"";
            while ([leader isEqualToString: @""]) {
                leader = [etcd getLeader];
            }
            
//            AMETCDResult* res = [etcd listDir:@"/groups" recursive:YES];
//            if(res.errCode == 0)
//            {
//                [self loadGroups: res];
//            }
//            else
//            {
//                [self createNewGroups:etcd];
//            }

            dispatch_async(dispatch_get_main_queue(), ^{
                self.clusterLeader.stringValue = leader;
                
            });
        });
    }
    
  //  self.userGroupTree.dataSource = self;
    return self;
}

-(void)loadGroups:(AMETCDResult*)res
{
    
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
    
    //return (item == nil) ? [FileSystemItem rootItem] : [(FileSystemItem *)item childAtIndex:index];
    return (item == nil) ? [AMUser rootItem] : [(AMUser *)item childAtIndex:index];
}


- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item {
    return (item == nil) ? @"Groups" : [item name];
}

@end
