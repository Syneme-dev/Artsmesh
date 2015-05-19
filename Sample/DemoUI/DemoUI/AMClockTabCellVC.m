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
#import "AMTimerTableCellVC.h"


#import "UIFramework/AMTableCellView.h"

@interface AMClockTabCellVC ()<AMPopUpViewDelegeate>
@property (weak) IBOutlet NSTextField *timeZoneAbbreviation;
@property (weak) IBOutlet   AMPopUpView*    groupPopup;
@property (nonatomic)       NSArray*        groups;
@property (nonatomic)       BOOL            isLocalGroup;
@end

@implementation AMClockTabCellVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.groupPopup.delegate = self;
    
    [self updateGroupPopup];
    [self.groupPopup selectItemAtIndex:0];
}

-(void) popupViewWillPopup:(AMPopUpView *)sender
{
    if ([sender isEqual:self.groupPopup]) {
        [self updateGroupPopup];
    }
}

- (void) updateGroupPopup
{
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

- (void)itemSelected:(AMPopUpView *)popupView
{
    if(popupView == self.groupPopup){
        AMLiveGroup *group = self.groups[self.groupPopup.indexOfSelectedItem];
        NSString* timeZoneName = group.timezoneName;
        NSTimeZone* zone = [NSTimeZone timeZoneWithName:timeZoneName];
        self.timeZoneAbbreviation.stringValue =[zone abbreviation];
    }
}

- (BOOL) isOnLine
{
    return [AMCoreData shareInstance].mySelf.isOnline;
}

- (BOOL)groupIsLocal:(AMLiveGroup *)group
{
    NSString *myGroupID = [[AMCoreData shareInstance] myLocalLiveGroup].groupId;
    return [group.groupId isEqualToString:myGroupID];
}


@end
