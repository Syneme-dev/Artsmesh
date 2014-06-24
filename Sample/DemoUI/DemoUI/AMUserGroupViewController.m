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
#import "AMMesher/AMAppObjects.h"
#import "AMUserGroupTableRowView.h"


@interface AMUserGroupViewController ()

@end

@implementation AMUserGroupViewController
{
    id _selectItem;
    NSArray *_localUsers;
    NSDictionary *_remoteGroups;
}

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
   [[NSNotificationCenter defaultCenter]
        addObserver:self
           selector:@selector(userGroupsChanged:)
               name:AM_LOCALUSERS_CHANGED
             object:nil];
    [[NSNotificationCenter defaultCenter]
        addObserver:self
        selector:@selector(userGroupsChanged:)
        name:AM_REMOTEGROUPS_CHANGED
        object:nil];
    
//    AMUser *user1 = [[AMUser alloc] init];
//    user1.nickName = @"user1";
//    AMUser *user2 = [[AMUser alloc] init];
//    user2.nickName = @"user2";
//    
//    AMUser *user3 = [[AMUser alloc] init];
//    user3.nickName = @"user3";
//    AMGroup *group1 = [[AMGroup alloc] init];
//    group1.groupName = @"group1";
//    group1.users = @[user3];
//    
//    AMUser *user4 = [[AMUser alloc] init];
//    user4.nickName = @"user4";
//    AMGroup *group2 = [[AMGroup alloc] init];
//    group2.groupName = @"group2";
//    group2.users = @[user4];
    
   // _localUsers = @[user1, user2];
//    _remoteGroups = @{
//        @"group1": group1,
//        @"group2": group2
//        };
    self.outlineView.dataSource = self;
    self.outlineView.delegate = self;
    [self.outlineView setRowHeight:22.0];
    [self.outlineView setTarget:self];
    [self.outlineView setDoubleAction:@selector(doubleClickOutlineView:)];
}


-(void)userGroupsChanged:(NSNotification*) notification
{
    if ([notification.name isEqual:AM_LOCALUSERS_CHANGED]) {
        _localUsers = [[AMAppObjects appObjects][AMLocalUsersKey] allValues];
    } else if ([notification.name isEqual:AM_REMOTEGROUPS_CHANGED]) {
        _remoteGroups = [AMAppObjects appObjects][AMRemoteGroupsKey];
    }
    
    [self.outlineView reloadData];
    [self.outlineView expandItem:nil expandChildren:YES];
}


- (IBAction)unmerge:(id)sender
{
     [[AMMesher sharedAMMesher] unmergeGroup];
}

- (IBAction)createGroupByEnter:(id)sender
{
    NSString* newGroupName = [self.createGroupTextField stringValue];
    if (newGroupName != nil && ![newGroupName isEqualToString:@""])
    {
        AMUser* mySelf = [[AMAppObjects appObjects] objectForKey:AMMyselfKey];
        if (mySelf.isOnline) {
            self.createGroupTextField.stringValue = @"You can't rename group after mesh!";
        }else{
            [[AMMesher sharedAMMesher] changeLocalGroupName:newGroupName];
            self.createGroupTextField.stringValue = @"";
        }
    }
}


-(void)doubleClickOutlineView:(id)sender{
    if([sender isKindOfClass:[NSOutlineView class]]){
        NSOutlineView* ov = (NSOutlineView*)sender;
        NSInteger selected = [ov selectedRow];
        
        if (selected < 0){
            return;
        }

        NSTableCellView *selectedCellView = [ov viewAtColumn:0 row:selected makeIfNecessary:YES];
        id item = selectedCellView.objectValue;
        if ([item isKindOfClass:[AMGroup class]]) {
            NSString* superGroupId = [item groupId];
            [[AMMesher sharedAMMesher] mergeGroup:superGroupId];
        }
    }
}


#pragma mark-
#pragma outlineView DataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    
    if (!item) {
        if (!_localUsers)
            return 0;
        else
            return _remoteGroups ? 2 : 1;
    } else if ([item isEqual:@"__localUsers"]) {
        return [_localUsers count];
    } else if ([item isEqual:@"__remoteGroups"]) {
        return [_remoteGroups count];
    } else if ([item isKindOfClass:[AMGroup class]]) {
        return [[(AMGroup *)item users] count];
    } else {
        return 0;
    }
}


- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    return [self outlineView:outlineView numberOfChildrenOfItem:item] > 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (!item) {
        if (index == 0) {
            return @"__localUsers";
        } else {
            return @"__remoteGroups";
        }
    } else if ([item isEqual:@"__localUsers"]) {
        return _localUsers[index];
    } else if ([item isEqual:@"__remoteGroups"]) {
        return [_remoteGroups allValues][index];
    } else if ([item isKindOfClass:[AMGroup class]]) {
        return [(AMGroup *)item users][index];
    } else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:nil
                                     userInfo:nil];
    }
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item{
    
    NSTableCellView* cellView = [outlineView makeViewWithIdentifier: @"ugcell" owner:self];
    [cellView setObjectValue:item];
    NSDictionary* userInfo = @{@"sender": cellView};
    
    if ([[cellView trackingAreas] count] == 0) {
         NSRect rect = [cellView bounds];
        NSTrackingArea* trackArea = [[NSTrackingArea alloc]
                                     initWithRect:rect
                                     options:(NSTrackingMouseEnteredAndExited  | NSTrackingMouseMoved|NSTrackingActiveInKeyWindow )
                                     owner:self
                                     userInfo:userInfo];
        [cellView addTrackingArea:trackArea];
    }
    
    NSString* title;
    if ([item isEqual:@"__localUsers"]) {
        //title = @"Local Users";
        title = [[AMAppObjects appObjects] objectForKey:AMClusterNameKey];
    } else if ([item isEqual:@"__remoteGroups"]) {
        title = @"Artsmesh";
    } else if ([item isKindOfClass:[AMGroup class]]) {
        title = [(AMGroup *)item groupName];
    } else if ([item isKindOfClass:[AMUser class]]) {
        title = [(AMUser *)item nickName];
    } else {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:nil
                                     userInfo:nil];
    }
    
    cellView.textField.stringValue = title;

    return cellView;
}

- (NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item
{
    AMUserGroupTableRowView* rowView = [[AMUserGroupTableRowView alloc] init];
    return rowView;
}

#pragma mark-
#pragma TableViewCell Tracking Area
- (void)mouseEntered:(NSEvent *)theEvent
{
    NSDictionary* userInfo = [theEvent userData];
    NSTableCellView* cellView = [userInfo objectForKey:@"sender"];
    _selectItem = cellView.objectValue;
    
    if ([_selectItem isKindOfClass:[AMGroup class]]) {
        [cellView addSubview:self.groupCellView];
        NSRect superRect = [cellView bounds];
        NSRect subRect = self.groupCellView.frame;
        int origX = superRect.size.width - subRect.size.width;
        subRect.origin = NSMakePoint(origX, 0);
        
        [self.groupCellView setFrame:subRect];
    }
}

- (void)mouseExited:(NSEvent *)theEvent
{
    [self.groupCellView removeFromSuperview];
}


@end
