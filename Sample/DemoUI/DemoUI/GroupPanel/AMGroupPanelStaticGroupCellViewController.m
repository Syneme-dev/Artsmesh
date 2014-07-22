//
//  AMGroupPanelStaticGroupCellViewController.m
//  DemoUI
//
//  Created by Wei Wang on 7/19/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMGroupPanelStaticGroupCellViewController.h"
#import "AMGroupPanelModel.h"
#import <AMNotificationManager/AMNotificationManager.h>
#import "AMGroupPanelTableCellView.h"

@interface AMGroupPanelStaticGroupCellViewController ()
@property (weak) IBOutlet NSButton *socialBtn;
@property (weak) IBOutlet NSButton *infoBtn;

@end

@implementation AMGroupPanelStaticGroupCellViewController

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
    [cellView.imageView setHidden:YES];
    
    if (self.staticUser != nil) {
        cellView.textField.stringValue = [self.staticUser name];
    }else if(self.staticGroup != nil){
        cellView.textField.stringValue = [self.staticGroup nickname];
    }

    [self.socialBtn setHidden:YES];
    [self.infoBtn setHidden:YES];
    
}


- (IBAction)socialBtnClicked:(NSButton *)sender
{
    NSString* groupName = self.staticGroup.nickname;
    NSDictionary *userInfo= [[NSDictionary alloc] initWithObjectsAndKeys:
                             groupName , @"GroupName", nil];
    [AMN_NOTIFICATION_MANAGER postMessage:userInfo withTypeName:AMN_SHOWGROUPINFO source:self];
}

- (IBAction)infoBtnClicked:(NSButton *)sender
{
    AMGroupPanelModel* model = [AMGroupPanelModel sharedGroupModel];
    model.selectedStaticGroup = self.staticGroup;
    model.detailPanelState = DetailPanelStaticGroup;
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
