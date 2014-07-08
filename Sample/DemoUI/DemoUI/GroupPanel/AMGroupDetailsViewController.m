//
//  AMGroupDetailsViewController.m
//  DemoUI
//
//  Created by Wei Wang on 7/1/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMGroupDetailsViewController.h"
#import "AMMesher/AMAppObjects.h"
#import "UIFramework/AMFoundryFontView.h"
#import "AMGroupPanelModel.h"
#import "AMMesher/AMMesher.h"
#import "AMGroupDetailsView.h"


@interface AMGroupDetailsViewController ()
@end


@implementation AMGroupDetailsViewController

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
    BOOL isMyGroup = [self.group isMyGroup];
    BOOL isMyMergedGroup = [self.group isMyMergedGroup];
    
    AMGroupDetailsView* detailView = (AMGroupDetailsView*)self.view;
    
    if ( isMyGroup || isMyMergedGroup) {
        [detailView.joinGroupBtn  setEnabled:NO];
    }else{
        [detailView.joinGroupBtn setEnabled:YES];
    }
}

- (IBAction)joinGroup:(NSButton *)sender
{
    AMMesher* mesher = [AMMesher sharedAMMesher];
    [mesher mergeGroup:self.group.groupId];
}

- (IBAction)cancelClick:(id)sender
{
    AMGroupPanelModel* model = [AMGroupPanelModel sharedGroupModel];
    model.detailPanelState = DetailPanelHide;
}

@end
