//
//  AMUserDetailsViewController.m
//  DemoUI
//
//  Created by Wei Wang on 7/2/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMUserDetailsViewController.h"
#import "AMGroupPanelModel.h"

@interface AMUserDetailsViewController ()

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

-(void)updateUI
{
    
}

- (IBAction)closeClick:(id)sender
{
    AMGroupPanelModel* model = [AMGroupPanelModel sharedGroupModel];
    model.detailPanelState = DetailPanelHide;
}

@end
