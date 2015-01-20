//
//  AMArchiveGroupCellContentView.m
//  DemoUI
//
//  Created by 王为 on 20/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMArchiveCellContentView.h"

@implementation AMArchiveCellContentView

-(instancetype)initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect]) {
        self.infoBtn = [self setThirdBtnWithImage:
                        [NSImage imageNamed:@"usergroup_info"]];
        
        [self.infoBtn setTarget:self];
        [self.infoBtn setAction:@selector(infoBtnClicked:)];

        
        self.socialBtn = [self setSecondBtnWithImage:
                         [NSImage imageNamed:@"user_Icon_FOAF"]];
        [self.socialBtn setTarget:self];
        [self.socialBtn setAction:@selector(socialBtnClicked:)];
        
    }
    
    return self;
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}


-(void)infoBtnClicked:(NSButton *)sender
{
    if([self.delegate respondsToSelector:@selector(infoBtnClickOnContentCellView:)]){
        [self.delegate infoBtnClickOnContentCellView:self];
    }
}


-(void)socialBtnClicked:(NSButton *)sender
{
    if([self.delegate respondsToSelector:@selector(socialBtnClickOnContentCellView:)]){
        [self.delegate socialBtnClickOnContentCellView:self];
    }
}


@end
