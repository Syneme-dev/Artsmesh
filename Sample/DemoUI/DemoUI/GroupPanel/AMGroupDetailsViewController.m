//
//  AMGroupDetailsViewController.m
//  DemoUI
//
//  Created by Wei Wang on 7/1/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMGroupDetailsViewController.h"
#import "UIFramework/AMFoundryFontView.h"
#import "AMMesher/AMMesher.h"
#import "UIFramework/AMButtonHandler.h"

@interface AMGroupDetailsViewController ()
@property (weak) IBOutlet NSButton *joinBtn;
@property (weak) IBOutlet NSButton *closeBtn;
@property (unsafe_unretained) IBOutlet NSTextView *groupDetailView;

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
    
    [self updateUI];
}

-(void)updateUI
{
    NSString* myGroupId = [AMCoreData shareInstance].myLocalLiveGroup.groupId;
    BOOL isMyGroup = [myGroupId isEqualToString:self.group.groupId];
    
    NSString* myMergedGroupId = [[AMCoreData shareInstance] mergedGroup].groupId;
    BOOL isMyMergedGroup = [myMergedGroupId isEqualToString:self.group.groupId];
    
    if ( isMyGroup || isMyMergedGroup) {
        [self.joinBtn  setEnabled:NO];
    }else{
        [self.joinBtn setEnabled:YES];
    }
    
    if (![self.group.description isEqualToString:@""]) {
        
        NSFont* textViewFont =  [NSFont fontWithName: @"FoundryMonoline" size: 13];
        NSDictionary* attr = @{NSForegroundColorAttributeName: [NSColor whiteColor],
                               NSFontAttributeName:textViewFont};
        NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:self.group.description attributes:attr];
        [self.groupDetailView.textStorage appendAttributedString:attrStr];
        [self.groupDetailView setNeedsDisplay:YES];
    }
}

- (IBAction)joinGroup:(NSButton *)sender
{
    [[AMMesher sharedAMMesher] mergeGroup:self.group.groupId];
}

- (IBAction)cancelClick:(id)sender
{
    if (self.hostVC) {
        [self.hostVC resignDetailView:self];
    }
}

@end
