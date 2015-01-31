//
//  AMArchiveGroupCellContentView.h
//  DemoUI
//
//  Created by 王为 on 20/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMOutlineCellContentView.h"  

@interface AMArchiveCellContentView : AMOutlineCellContentView

@property NSButton *infoBtn;
@property NSButton *socialBtn;

@end


@protocol AMArchiveCellContentViewDelegate <AMOutlineCellContentViewDelegate>

@optional
-(void)infoBtnClickOnContentCellView:(AMArchiveCellContentView *)contentCellView;
-(void)socialBtnClickOnContentCellView:(AMArchiveCellContentView *)contentCellView;

@end
