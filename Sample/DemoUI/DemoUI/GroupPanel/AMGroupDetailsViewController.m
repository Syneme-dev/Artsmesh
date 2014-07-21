//
//  AMGroupDetailsViewController.m
//  DemoUI
//
//  Created by Wei Wang on 7/1/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMGroupDetailsViewController.h"
#import "UIFramework/AMFoundryFontView.h"
#import "AMGroupPanelModel.h"
#import "AMGroupDetailsView.h"
#import "AMMesher/AMMesher.h"


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
    NSString* myGroupId = [AMCoreData shareInstance].myLocalLiveGroup.groupId;
    BOOL isMyGroup = [myGroupId isEqualToString:self.group.groupId];
    
    NSString* myMergedGroupId = [AMCoreData shareInstance].mergedGroupId;
    BOOL isMyMergedGroup = [myMergedGroupId isEqualToString:self.group.groupId];
    
    AMGroupDetailsView* detailView = (AMGroupDetailsView*)self.view;
    
    if ( isMyGroup || isMyMergedGroup) {
        [detailView.joinGroupBtn  setEnabled:NO];
    }else{
        [detailView.joinGroupBtn setEnabled:YES];
    }
}

- (IBAction)joinGroup:(NSButton *)sender
{
    [[AMMesher sharedAMMesher] mergeGroup:self.group.groupId];
}

- (IBAction)cancelClick:(id)sender
{
    AMGroupPanelModel* model = [AMGroupPanelModel sharedGroupModel];
    model.detailPanelState = DetailPanelHide;
}

@end
