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

-(void)updateUI;

//For subclass
-(void)autoHideBtn:(NSButton *)btn;
-(void)removeAutoHideBtn:(NSButton *)btn;
-(NSButton *)setFirstBtnWithImage:(NSImage *)image;
-(NSButton *)setSecondBtnWithImage:(NSImage *)image;
-(NSButton *)setThirdBtnWithImage:(NSImage *)image;
-(void)removeBtnAtPos:(int)pos;

-(NSImageView *)setFirstIconWithImage:(NSImage *)image;
-(NSImageView *)setSecondIconWithImage:(NSImage *)image;
-(void)removeIconAtPos:(int)pos;

@end


@protocol AMOutlineCellContentViewDataSource <NSObject>

-(BOOL)hideBar;
-(NSImage *)barImage;
-(NSString *)title;

@end


@protocol AMOutlineCellContentViewDelegate <NSObject>

@optional

-(void)doubleClickOnCellContentView:(AMOutlineCellContentView *)cellContentView;

@end
