//
//  AMLocalGroupCellContentView.m
//  DemoUI
//
//  Created by 王为 on 19/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMGroupCellContentView.h"

@implementation AMGroupCellContentView


-(instancetype)initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect]) {
        self.infoBtn = [self setThirdBtnWithImage:
                        [NSImage imageNamed:@"usergroup_info"]];
        
        [self.infoBtn setTarget:self];
        [self.infoBtn setAction:@selector(infoBtnClicked:)];
        
        self.mergeBtn = [self setFirstBtnWithImage:
                         [NSImage imageNamed:@"SideBar_group_h"]];
        [self.mergeBtn setTarget:self];
        [self.mergeBtn setAction:@selector(mergeBtnClicked:)];
        
        self.leaveBtn = [self setSecondBtnWithImage:
                         [NSImage imageNamed:@"group_exit"]];
        [self.leaveBtn setTarget:self];
        [self.leaveBtn setAction:@selector(leaveBtnClicked:)];
        
        self.broadcastIcon = [self setFirstIconWithImage:
                              [NSImage imageNamed:@"group_broadcast"]];
        self.lockedIcon = [self setSecondIconWithImage:
                           [NSImage imageNamed:@"group_lock_icon"]];
        
    }
    
    return self;
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    
}


-(void)updateUI
{
    [super updateUI];
    
    if([self.dataSource isBroadcasting]){
        [self.broadcastIcon setHidden:NO];
    }else{
        [self.broadcastIcon setHidden:YES];
    }
    
    if ([self.dataSource isLocked]) {
        [self.lockedIcon setHidden:NO];
    }else{
        [self.lockedIcon setHidden:YES];
    }
    
    if ([self.dataSource canLeave]) {
        [self.leaveBtn setHidden:NO];
        [self.leaveBtn setEnabled:YES];
    }else{
        [self.leaveBtn setHidden:YES];
        [self.leaveBtn setEnabled:NO];
    }
    
    if ([self.dataSource canMerge]) {
        [self.mergeBtn setHidden:NO];
        [self.mergeBtn setEnabled:YES];
    }else{
        [self.mergeBtn setHidden:YES];
        [self.mergeBtn setEnabled:NO];
    }
}


-(void)infoBtnClicked:(NSButton *)sender
{
    if([self.delegate respondsToSelector:@selector(infoBtnClickOnContentCellView:)]){
        [self.delegate infoBtnClickOnContentCellView:self];
    }
}


-(void)mergeBtnClicked:(NSButton *)sender
{
    if([self.delegate respondsToSelector:@selector(mergeBtnClickOnContentCellView:)]){
        [self.delegate mergeBtnClickOnContentCellView:self];
    }
}


-(void)leaveBtnClicked:(NSButton *)sender
{
    if([self.delegate respondsToSelector:@selector(leaveBtnClickOnContentCellView:)]){
        [self.delegate leaveBtnClickOnContentCellView:self];
    }
}


@end
