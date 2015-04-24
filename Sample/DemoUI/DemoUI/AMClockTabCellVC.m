//
//  AMClockTabCellVC.m
//  Artsmesh
//
//  Created by whiskyzed on 4/20/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMClockTabCellVC.h"
#import "UIFramework/AMPopUpview.h"
#import "AMCoreData/AMCoreData.h"
#import "AMCoreData/AMLiveGroup.h"
#import "AMCoreData/AMLiveUser.h"


@interface AMClockTabCellVC ()<AMPopUpViewDelegeate>
@property (weak) IBOutlet   AMPopUpView*    groupPopup;
@property (nonatomic)       NSArray*        groups;
@property (nonatomic)       BOOL            isLocalGroup;
@end

@implementation AMClockTabCellVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.groupPopup.delegate = self;
    // Do view setup here.
}

-(void) popupViewWillPopup:(AMPopUpView *)sender
{
    if ([sender isEqual:self.groupPopup]) {
        self.groups = [[AMCoreData shareInstance] myMergedGroupsInFlat];
        self.isLocalGroup = NO;
        
        if (!self.groups) {
            self.groups = @[ [[AMCoreData shareInstance] myLocalLiveGroup] ];
            self.isLocalGroup = YES;
        }
        [self.groupPopup removeAllItems];
        
        NSMutableArray *groupNames = [NSMutableArray array];
        [groupNames addObjectsFromArray:[self.groups valueForKeyPath:@"groupName"]];
        [self.groupPopup addItemsWithTitles:groupNames];
    }
}

@end
