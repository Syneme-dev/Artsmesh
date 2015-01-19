//
//  AMOutlineCellContentView.h
//  DemoUI
//
//  Created by 王为 on 19/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UIFramework/AMFoundryFontView.h"

@interface AMOutlineCellContentView : NSView

@property NSImageView *barView;
@property AMFoundryFontView *titleField;
@property (weak)id dataSource;
@property (weak)id delegate;

//private
-(void)autoHideBtn:(NSButton *)btn;
-(void)removeAutoHideBtn:(NSButton *)btn;

@end


@protocol AMOutlineCellContentViewDataSource <NSObject>

-(BOOL)hideBar;
-(NSColor *)barColor;
-(NSString *)title;

@end


@protocol AMOutlineCellContentViewDelegate <NSObject>

@optional

-(void)doubleClickOnCellContentView:(AMOutlineCellContentView *)cellContentView;

@end
