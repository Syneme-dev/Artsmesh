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
#import "AMUserGroupTableCellView.h"
#import "AMUserGroupNode.h"

@interface AMUserGroupViewController ()

@end

@implementation AMUserGroupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        
        NSTextField *textField = self.createGroupTextField;
        NSColor *insertionPointColor = [NSColor whiteColor];
        NSTextView *fieldEditor = (NSTextView*)[textField.window
                                                fieldEditor:YES
                                                forObject:textField];
        
        fieldEditor.insertionPointColor = insertionPointColor;
    }
    
    return self;
}

-(void)awakeFromNib{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userGroupsChanged:) name:AM_USERGROUPS_CHANGED object:nil];
}

-(void)userGroupsChanged:(NSNotification*) notification
{
    AMMesher* mehser = [AMMesher sharedAMMesher];
    NSArray* usergroups = mehser.userGroups;
    
    NSMutableArray* newUserGroupNodes = [[NSMutableArray alloc]  init];
    for (AMGroup* group in usergroups) {
        AMUserGroupNode* newGroupNode = [[AMUserGroupNode alloc] init];
        newGroupNode.nodeName = [group.groupName isEqualToString:@""]?@"Artsmesh":group.groupName;
        newGroupNode.isLeaf = NO;
        newGroupNode.parent = nil;
        newGroupNode.children = [[NSMutableArray alloc] init];
        
        for(AMUser* user in group.users){
            AMUserGroupNode* newUserNode = [[AMUserGroupNode alloc] init];
            newUserNode.nodeName = user.nickName;
            newUserNode.isLeaf = YES;
            newUserNode.parent = newGroupNode;
            newUserNode.children = nil;
            [newGroupNode addChildrenObject:newUserNode];
        }
        
        [newUserGroupNodes addObject:newGroupNode];
    }
    
    [self willChangeValueForKey:@"userGroupNodes"];
    self.userGroupNodes = newUserGroupNodes;
    [self didChangeValueForKey:@"userGroupNodes"];

}



- (IBAction)joinGroup:(id)sender
{
    if ([[sender superview] isKindOfClass:[AMUserGroupTableCellView class]])
    {
        AMUserGroupTableCellView* cellView = (AMUserGroupTableCellView*)[sender superview];
        
        if([cellView.objectValue isKindOfClass:[AMUserGroupNode class]])
        {
            AMUserGroupNode* node = cellView.objectValue;;
            [[AMMesher sharedAMMesher] joinGroup:node.nodeName];
        }
    }
}

- (IBAction)createGroup:(id)sender
{
    NSString* createName = [self.createGroupTextField stringValue];
    if (createName != nil && ![createName isEqualToString:@""])
    {
        [[AMMesher sharedAMMesher] joinGroup:createName];
    }
}

- (IBAction)quitGroup:(id)sender
{
    if ([[sender superview] isKindOfClass:[AMUserGroupTableCellView class]])
    {
        AMUserGroupTableCellView* cellView = (AMUserGroupTableCellView*)[sender superview];
        
        if([cellView.objectValue isKindOfClass:[AMUserGroupNode class]])
        {
            AMUserGroupNode* node = cellView.objectValue;
            if ([node.nodeName isEqualToString:@"Artsmesh"])
            {
                    return;
            }
            [[AMMesher sharedAMMesher] backToArtsmesh];
        }
    }
}

- (IBAction)createGroupByEnter:(id)sender
{
    NSString* createName = [self.createGroupTextField stringValue];
    if (createName != nil && ![createName isEqualToString:@""])
    {
        [[AMMesher sharedAMMesher] joinGroup:createName];
    }
}



@end
