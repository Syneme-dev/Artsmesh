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

@interface AMGroupDetailsViewController ()

@property (weak) IBOutlet NSButton *joinBtn;
@property (weak) IBOutlet NSButton *leaderBtn;
@property (weak) IBOutlet NSButton *commitBtn;
@property (weak) IBOutlet NSButton *cancelBtn;
@property (weak) IBOutlet NSButton *changePasswordBtn;
@property (weak) IBOutlet AMFoundryFontView *leaderField;

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
    AMUser* leader = [self.group leader];
    self.leaderField.stringValue = leader.nickName;
    
    BOOL isMyGroup = [self.group isMyGroup];
    BOOL isMyMergedGroup = [self.group isMyMergedGroup];
    
    
    if ( isMyGroup || isMyMergedGroup) {
        [self.joinBtn setEnabled:NO];
    }else{
        [self.joinBtn setEnabled:YES];
    }
    
    AMUser* mySelf =[AMAppObjects appObjects][AMMyselfKey];
    if (isMyGroup || mySelf.isLeader) {
        [self.leaderBtn setEnabled:NO];
    }else{
        [self.leaderBtn setEnabled:NO];
    }
}

- (IBAction)cancelClick:(id)sender
{
    AMGroupPanelModel* model = [AMGroupPanelModel sharedGroupModel];
    model.detailPanelState = DetailPanelHide;
}

@end
