//
//  AMLocalGroupCellContentView.h
//  DemoUI
//
//  Created by 王为 on 19/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMOutlineCellContentView.h"

@interface AMLocalGroupCellContentView : AMOutlineCellContentView

@property NSImageView *broadcastIcon;
@property NSButton *infoBtn;

@end


@protocol AMLocalGroupCellContentViewDataSource <AMOutlineCellContentViewDataSource>

-(BOOL)isBroadcasting;

@end


@protocol AMLocalGroupCellContentViewDelegate <AMOutlineCellContentViewDelegate>

@optional
-(void)infoBtnClickOnContentCellView:(AMLocalGroupCellContentView *)contentCellView;


@end
