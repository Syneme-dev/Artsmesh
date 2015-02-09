//
//  AMLocalGroupCellContentView.h
//  DemoUI
//
//  Created by 王为 on 19/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMOutlineCellContentView.h"

@interface AMGroupCellContentView : AMOutlineCellContentView

@property NSImageView *broadcastIcon;
@property NSImageView *lockedIcon;
@property NSButton *infoBtn;
@property NSButton *mergeBtn;
@property NSButton *leaveBtn;

@end


@protocol AMGroupCellContentViewDataSource <AMOutlineCellContentViewDataSource>

-(BOOL)isBroadcasting;
-(BOOL)isLocked;
-(BOOL)canMerge;
-(BOOL)canLeave;

@end


@protocol AMGroupCellContentViewDelegate <AMOutlineCellContentViewDelegate>

@optional
-(void)infoBtnClickOnContentCellView:(AMGroupCellContentView *)contentCellView;
-(void)mergeBtnClickOnContentCellView:(AMGroupCellContentView *)contentCellView;
-(void)leaveBtnClickOnContentCellView:(AMGroupCellContentView *)contentCellView;


@end
