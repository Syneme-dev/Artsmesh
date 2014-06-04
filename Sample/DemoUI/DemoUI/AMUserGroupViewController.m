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
{
    id _selectItem;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userGroupsChanged:) name:AM_USERGROUPS_CHANGED object:nil];
    
    self.outlineView.dataSource = self;
    self.outlineView.delegate = self;
    [self.outlineView setRowHeight:30.0];
}

-(void)userGroupsChanged:(NSNotification*) notification
{
    AMMesher* mehser = [AMMesher sharedAMMesher];
    self.userGroups = mehser.userGroups;
    
    [self.outlineView reloadData];
}


- (IBAction)joinGroup:(id)sender
{
    if ([[sender title] isEqualToString:@"Join"]) {
         [[AMMesher sharedAMMesher] joinGroup:[_selectItem groupName]];
    }else{
        [[AMMesher sharedAMMesher] backToArtsmesh];
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


- (IBAction)createGroupByEnter:(id)sender
{
    NSString* createName = [self.createGroupTextField stringValue];
    if (createName != nil && ![createName isEqualToString:@""])
    {
        [[AMMesher sharedAMMesher] joinGroup:createName];
    }
}


#pragma mark-
#pragma outlineView DataSource

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item {
    
    if (item == nil) {
        if (self.userGroups == nil){
            return 0;
        }else{
            return [self.userGroups count];
        }
    }
    
    if ([item isKindOfClass:[AMGroup class]]) {
        AMGroup* group = (AMGroup*)item;
        return [group.users count];
    }

    return 0;
}


- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item {
    if (item == nil) {
        return YES;
    }else if([item isKindOfClass:[AMGroup class]]){
        AMGroup* group = (AMGroup*)item;
        return [group.users count] != 0;
    }else{
        return NO;
    }
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item {
    if (item == nil) {
        if (self.userGroups == nil) {
            return nil;
        }else{
            return [self.userGroups objectAtIndex:0];
        }
    }else{
        if ([item isKindOfClass:[AMGroup class]]) {
            AMGroup* group  = (AMGroup*)item;
            return [group.users objectAtIndex:index];
        }else{
            return nil;
        }
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
                                     options:(NSTrackingMouseEnteredAndExited  |NSTrackingActiveInKeyWindow )
                                     owner:self
                                     userInfo:userInfo];
        [cellView addTrackingArea:trackArea];
    }
    
    NSString* title;
    if ([item isKindOfClass:[AMGroup class]]) {
        AMGroup* group = (AMGroup*)item;
        title = group.groupName;
        if ([title isEqualToString:@""]) {
            title = @"Artsmesh";
        }
    }else{
        AMUser* user = (AMUser*)item;
        title = user.nickName;
    }
    
    cellView.textField.stringValue = title;

    return cellView;
}

#pragma mark-
#pragma TableViewCell Tracking Area
- (void)mouseEntered:(NSEvent *)theEvent
{
    NSDictionary* userInfo = [theEvent userData];
    NSTableCellView* cellView = [userInfo objectForKey:@"sender"];
    _selectItem = cellView.objectValue;
    
    if ([_selectItem isKindOfClass:[AMGroup class]]) {
        if ([[_selectItem groupName ] isEqualToString:@"Artsmesh"]) {
            _selectItem = @"";
        }
        
        AMMesher* mesher = [AMMesher sharedAMMesher];
        if ([mesher.mySelf.groupName isEqualToString:[_selectItem groupName]]) {
            self.groupCellViewJoinBtn.title = @"Leave";
        }else{
            self.groupCellViewJoinBtn.title = @"Join";
        }
        
        [cellView addSubview:self.groupCellView];
    }
}

- (void)mouseExited:(NSEvent *)theEvent
{
    [self.groupCellView removeFromSuperview];
    
    //cellView.textField.stringValue = @"Mouse Exited!";
}


@end
