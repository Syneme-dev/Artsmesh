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
#import <UIFramework/AMButtonHandler.h>


@interface AMGroupDetailsViewController ()

@property (weak) IBOutlet NSButton *joinBtn;
@property (weak) IBOutlet NSButton *cancelBtn;
@property (weak) IBOutlet AMFoundryFontView *groupDescField;

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
    [AMButtonHandler changeTabTextColor:self.joinBtn toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.cancelBtn toColor:UI_Color_blue];
    
    BOOL isMyGroup = [self.group isMyGroup];
    BOOL isMyMergedGroup = [self.group isMyMergedGroup];
    
    if ( isMyGroup || isMyMergedGroup) {
        [self.joinBtn setEnabled:NO];
    }else{
        [self.joinBtn setEnabled:YES];
    }
    
    [self.groupDescField setStringValue:self.group.description];
}

- (IBAction)cancelClick:(id)sender
{
    AMGroupPanelModel* model = [AMGroupPanelModel sharedGroupModel];
    model.detailPanelState = DetailPanelHide;
}

@end
