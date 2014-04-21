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
        
        NSTextField *textField = self.createGroupTextField;
        NSColor *insertionPointColor = [NSColor whiteColor];
        NSTextView *fieldEditor = (NSTextView*)[textField.window
                                                fieldEditor:YES
                                                forObject:textField];
        
        fieldEditor.insertionPointColor = insertionPointColor;
    }
    
    return self;
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
    NSString* createName = [self.createGroupTextField stringValue];
    if (createName != nil && ![createName isEqualToString:@""])
    {
        [[AMMesher sharedAMMesher] joinGroup:createName];
    }
}

- (IBAction)quitGroup:(id)sender
{
    [[AMMesher sharedAMMesher] backToArtsmesh];
}

- (IBAction)createGroupByEnter:(id)sender
{
    NSString* createName = [self.createGroupTextField stringValue];
    if (createName != nil && ![createName isEqualToString:@""])
    {
        [[AMMesher sharedAMMesher] joinGroup:createName];
    }
}

- (IBAction)mergeGroup:(id)sender
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
        
        [[AMMesher sharedAMMesher] everyoneJoinGroup:groupName];
    }

}


- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    
}


@end
