//
//  AMGroupPanelStaticLabelController.m
//  DemoUI
//
//  Created by Wei Wang on 7/22/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMGroupPanelStaticLabelController.h"
#import "AMGroupPanelTableCellView.h"
#import "AMStatusNet/AMStatusNet.h"


@interface AMGroupPanelStaticLabelController ()

@end

@implementation AMGroupPanelStaticLabelController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (IBAction)refreshBtnClick:(NSButton *)sender
{
     [[AMStatusNet shareInstance] loadGroups];
}

-(void)updateUI
{
    AMGroupPanelTableCellView* cellView = (AMGroupPanelTableCellView*)self.view;
    [cellView.imageView setHidden:YES];
    cellView.textField.stringValue = @"Archive Groups";
}

@end
