//
//  AMGroupPanelUserCellController.m
//  AMGroupOutlineTest
//
//  Created by 王 为 on 6/27/14.
//  Copyright (c) 2014 王 为. All rights reserved.
//

#import "AMGroupPanelUserCellController.h"
#import "AMGroupPanelModel.h"
#import "AMGroupTextFieldFormatter.h"
#import "AMGroupPanelTableCellView.h"

#define MAX_USER_NAME_LENGTH 16

@interface AMGroupPanelUserCellController ()
@property (weak) IBOutlet NSButton *leaderBtn;
@property (weak) IBOutlet NSButton *zombieBtn;
@property (weak) IBOutlet NSButton *infoBtn;

@end

@implementation AMGroupPanelUserCellController

-(void)awakeFromNib
{
    [super awakeFromNib];
}

-(void)updateUI
{
    AMGroupPanelTableCellView* cellView = (AMGroupPanelTableCellView*)self.view;
    [cellView.textField setEditable:NO];
    cellView.textField.stringValue = self.user.nickName;
    if (self.user.isOnline) {
        [cellView.imageView setImage:[NSImage imageNamed:@"user_online"]];
    }else{
        [cellView.imageView setImage:[NSImage imageNamed:@"user_offline"]];
    }
    
    if ([self.group.leaderId isEqualToString:self.user.userid]) {
        [self.leaderBtn setHidden:NO];
    }else{
        [self.leaderBtn setHidden:YES];
    }
    
    if (self.user.isOnline && self.localUser) {
        [self.zombieBtn setHidden:NO];
    }else{
        [self.zombieBtn setHidden:YES];
    }
    
    [self.infoBtn setHidden:YES];
}


- (IBAction)infoBtnClick:(id)sender
{
    AMGroupPanelModel* model = [AMGroupPanelModel sharedGroupModel];
    model.selectedUser = self.user;
    model.detailPanelState = DetailPanelUser;
}

-(void)cellViewDoubleClicked:(id)sender
{
    [self.infoBtn performClick:sender];
}


#pragma mark-
#pragma TableViewCell Tracking Area
- (void)mouseEntered:(NSEvent *)theEvent
{
    [self.infoBtn setHidden:NO];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    [self.infoBtn setHidden:YES];
}


@end
