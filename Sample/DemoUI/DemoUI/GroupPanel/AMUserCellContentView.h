//
//  AMUserCellContentView.h
//  DemoUI
//
//  Created by 王为 on 19/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMOutlineCellContentView.h"

@interface AMUserCellContentView : AMOutlineCellContentView

@property NSImageView *leaderIcon;
@property NSImageView *oscIcon;
@property NSImageView *ipv6Icon;
@property NSButton *infoBtn;

@end


@protocol AMUserCellContentViewDataSource <AMOutlineCellContentViewDataSource>

-(BOOL)isLeader;
-(BOOL)isRunningOSC;

@end


@protocol AMUserCellContentViewDelegate <AMOutlineCellContentViewDelegate>

@optional
-(void)infoBtnClickOnContentCellView:(AMUserCellContentView *)contentCellView;


@end