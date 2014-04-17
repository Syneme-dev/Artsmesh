//
//  AMUserGroupViewController.m
//  DemoUI
//
//  Created by Wei Wang on 4/1/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMUserGroupViewController.h"
#import "AMMesher/AMMesher.h"
#import "AMMesher/AMGroup.h"

@interface AMUserGroupViewController ()

@end

@implementation AMUserGroupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        self.sharedMesher  =  [AMMesher sharedAMMesher];
    }
    
    return self;
}

-(void)clearEveryThing
{
    
}

- (IBAction)joinGroup:(id)sender
{
    long index = [self.userGroupOutline selectedRow];
    if (index == -1)
    {
        return;
    }
    
    id selectedItem = [self.userGroupOutline itemAtRow:index];
    if(selectedItem)
    {
        NSTreeNode* node = selectedItem;
        AMGroup* toJoinGroup = node.representedObject;
        NSString* groupName = toJoinGroup.uniqueName;
        
        [[AMMesher sharedAMMesher] joinGroup:groupName];
    }
}

- (IBAction)createGroup:(id)sender
{
    NSString* createName = [self.createGroupName stringValue];
    if (createName != nil && ![createName isEqualToString:@""])
    {
        [[AMMesher sharedAMMesher] createGroup:createName];
    }
}

- (IBAction)quitGroup:(id)sender
{
    [[AMMesher sharedAMMesher] backToArtsmesh];
}

- (void)outlineViewSelectionIsChanging:(NSNotification *)notification
{
    id selectedItem = [self.userGroupOutline itemAtRow:[self.userGroupOutline selectedRow]];
    
    if([selectedItem isLeaf])
    {
        [self.joinGroupButton setEnabled:NO];
    }
    else
    {
        [self.joinGroupButton setEnabled:YES];
    }
}

@end
