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
    if ([[sender superview] isKindOfClass:[AMUserGroupTableCellView class]])
    {
        AMUserGroupTableCellView* cellView = (AMUserGroupTableCellView*)[sender superview];
        
        if([cellView.objectValue isKindOfClass:[AMUserGroupNode class]])
        {
            AMUserGroupNode* node = cellView.objectValue;
            if ([node isKindOfClass:[AMGroup class]])
            {
                AMGroup* group = (AMGroup*)node;
                NSString* groupName = group.uniqueName;
                [[AMMesher sharedAMMesher] joinGroup:groupName];
            }
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
    
    if ([[sender superview] isKindOfClass:[AMUserGroupTableCellView class]])
    {
        AMUserGroupTableCellView* cellView = (AMUserGroupTableCellView*)[sender superview];
        
        if([cellView.objectValue isKindOfClass:[AMUserGroupNode class]])
        {
            AMUserGroupNode* node = cellView.objectValue;
            if ([node isKindOfClass:[AMGroup class]])
            {
                AMGroup* group = (AMGroup*)node;
                NSString* groupName = group.uniqueName;
                [[AMMesher sharedAMMesher] everyoneJoinGroup:groupName];
            }
        }
    }
}


- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    
}


@end
