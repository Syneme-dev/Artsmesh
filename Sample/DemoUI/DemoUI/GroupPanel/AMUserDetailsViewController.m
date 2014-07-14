//
//  AMUserDetailsViewController.m
//  DemoUI
//
//  Created by Wei Wang on 7/2/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMUserDetailsViewController.h"
#import "AMGroupPanelModel.h"
#import "UIFramework/AMCheckBoxView.h"

@interface AMUserDetailsViewController ()
@property (weak) IBOutlet AMCheckBoxView *isLeader;
@property (weak) IBOutlet AMCheckBoxView *isMeshed;

@end

@implementation AMUserDetailsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)awakeFromNib
{
    self.isLeader.title = @"LEADER";
    self.isMeshed.title = @"MESHED";
    self.isLeader.readOnly = YES;
    self.isMeshed.readOnly = YES;
}

-(void)updateUI
{
    self.isLeader.checked = self.user.isLeader;
    self.isMeshed.checked = self.user.isOnline;
}

- (IBAction)closeClick:(id)sender
{
    AMGroupPanelModel* model = [AMGroupPanelModel sharedGroupModel];
    model.detailPanelState = DetailPanelHide;
}

@end
