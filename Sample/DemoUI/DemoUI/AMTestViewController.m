//
//  AMTestViewController.m
//  DemoUI
//
//  Created by xujian on 6/5/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMTestViewController.h"
#import "AMRestHelper.h"
#import "AMPopupMenuItem.h"
#import "AMPanelViewController.h"
#import <AMNotificationManager/AMNotificationManager.h>
#import "AMAppDelegate.h"
#import <AMPreferenceManager/AMPreferenceManager.h>
#import "UIFramework/AMBox.h"
#import "UIFramework/AMBoxItem.h"

@interface AMTestViewController ()

@end

@implementation AMTestViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
              // Initialization code here.
    }
    return self;
}

-(void)awakeFromNib{
    NSArray *itemTitles = [NSArray arrayWithObjects:@"itemtest",@"itemtest2",@"one",nil];
    [self.popUpButton removeAllItems];
    [self.popUpButton addItemsWithTitles:itemTitles];
    [self.popUpButton setPullsDown:YES];
    NSMenu *newMenu = [[NSMenu alloc] init];
    NSArray *itemArray = [self.popUpButton itemArray];
//    NSDictionary *attributes = [NSDictionary
//                                dictionaryWithObjectsAndKeys:
//                                [NSColor whiteColor], NSForegroundColorAttributeName,
//                                [NSFont systemFontOfSize: [NSFont systemFontSize]],
//                                NSFontAttributeName, nil];

    
    for (int i = 0; i < [itemArray count]; i++)
    {
        NSMenuItem *item = [itemArray objectAtIndex:i];
//        NSAttributedString *as = [[NSAttributedString alloc]
//                                  initWithString:[item title]
//                                  attributes:attributes];
//        [item setAttributedTitle:as];
        AMPopupMenuItem *popMenuItem=[[AMPopupMenuItem alloc]initWithTitle:item.title  keyEquivalent:@"" width:self.popUpButton.frame.size.width];
        popMenuItem.popupButton=self.popUpButton;
        [popMenuItem setEnabled:YES];
        [popMenuItem setTarget:self];
        [newMenu addItem:popMenuItem];
        
    }
    [self.popUpButton setMenu:newMenu];

}

-(void) postNotificationShowUser
{
    NSDictionary *userInfo= [[NSDictionary alloc] initWithObjectsAndKeys:
                                                 @"wangwei", @"UserName", nil];
    [AMN_NOTIFICATION_MANAGER postMessage:userInfo withTypeName:AMN_SHOWUSERINFO source:self];
}

- (IBAction)ShowUserButtonClick:(id)sender {
   
    
//    [self postNotificationShowUser];
}
- (IBAction)ShowGroupButtonClick:(id)sender {
    NSDictionary *userInfo= [[NSDictionary alloc] initWithObjectsAndKeys:
                            self.groupNameText.stringValue , @"GroupName", nil];
    [AMN_NOTIFICATION_MANAGER postMessage:userInfo withTypeName:AMN_SHOWGROUPINFO source:self];
}
@end
