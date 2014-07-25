//
//  AMGroupPanelStaticUserCellController.m
//  DemoUI
//
//  Created by Wei Wang on 7/22/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMGroupPanelStaticUserCellController.h"
#import "AMGroupPanelTableCellView.h"
#import <AMNotificationManager/AMNotificationManager.h>
#import "AMGroupPanelModel.h"

@interface AMGroupPanelStaticUserCellController ()
@property (weak) IBOutlet NSButton *socialBtn;
@property (weak) IBOutlet NSButton *infoBtn;

@end

@implementation AMGroupPanelStaticUserCellController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)updateUI
{
    AMGroupPanelTableCellView* cellView = (AMGroupPanelTableCellView*)self.view;
    cellView.textField.stringValue = [self.staticUser name];
    [cellView.textField setEditable:NO];
    [cellView.imageView setImage:[NSImage imageNamed:@"user_offline"]];
    
    [self.socialBtn setHidden:YES];
    [self.infoBtn setHidden:YES];
}


- (IBAction)socialBtnClicked:(NSButton *)sender
{
    NSString* name = self.staticUser.name;
    NSDictionary *userInfo= [[NSDictionary alloc] initWithObjectsAndKeys:
                             name , @"UserName", nil];
    [AMN_NOTIFICATION_MANAGER postMessage:userInfo withTypeName:AMN_SHOWUSERINFO source:self];
}

- (IBAction)infoBtnClicked:(NSButton *)sender
{
    AMGroupPanelModel* model = [AMGroupPanelModel sharedGroupModel];
    model.selectedStaticUser = self.staticUser;
    model.detailPanelState = DetailPanelStaticUser;
}

-(void)cellViewDoubleClicked:(id)sender
{
    [self.infoBtn performClick:sender];
}

#pragma mark-
#pragma TableViewCell Tracking Area
- (void)mouseEntered:(NSEvent *)theEvent
{
    [self.socialBtn setHidden:NO];
    [self.infoBtn setHidden:NO];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    [self.socialBtn setHidden:YES];
    [self.infoBtn setHidden:YES];
}

@end
