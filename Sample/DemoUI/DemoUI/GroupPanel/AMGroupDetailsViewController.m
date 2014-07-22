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
#import "AMGroupPanelDetailView.h"
#import "AMMesher/AMMesher.h"
#import "UIFramework/AMButtonHandler.h"

@interface AMGroupDetailsViewController ()
@property (weak) IBOutlet NSButton *joinBtn;
@property (weak) IBOutlet NSButton *closeBtn;

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


-(void)awakeFromNib
{
    [AMButtonHandler changeTabTextColor:self.closeBtn toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.joinBtn toColor:UI_Color_blue];
}

-(void)updateUI
{
    NSString* myGroupId = [AMCoreData shareInstance].myLocalLiveGroup.groupId;
    BOOL isMyGroup = [myGroupId isEqualToString:self.group.groupId];
    
    NSString* myMergedGroupId = [AMCoreData shareInstance].mergedGroupId;
    BOOL isMyMergedGroup = [myMergedGroupId isEqualToString:self.group.groupId];
    
    if ( isMyGroup || isMyMergedGroup) {
        [self.joinBtn  setEnabled:NO];
    }else{
        [self.joinBtn setEnabled:YES];
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
