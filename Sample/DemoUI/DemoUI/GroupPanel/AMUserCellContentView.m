//
//  AMUserCellContentView.m
//  DemoUI
//
//  Created by 王为 on 19/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMUserCellContentView.h"

@implementation AMUserCellContentView

-(instancetype)initWithFrame:(NSRect)frameRect
{
    if (self = [super initWithFrame:frameRect]) {
        
        CGFloat height = self.titleField.frame.size.height;
        CGFloat width = height;
        CGFloat x = frameRect.origin.x + frameRect.size.width - width - 5;
        CGFloat y = self.titleField.frame.origin.y;
        
        NSRect infoBtnRect = NSMakeRect(x, y, width, height);
        _infoBtn = [[NSButton alloc] initWithFrame:infoBtnRect];
        _infoBtn.image = [NSImage imageNamed:@"usergroup_info"];
        [_infoBtn setTarget:self];
        [_infoBtn setAction:@selector(infoBtnClicked:)];
        [self autoHideBtn:_infoBtn];
        
        NSRect oscRect = infoBtnRect;
        oscRect.origin.x -= infoBtnRect.size.width * 2;
        _oscIcon = [[NSImageView alloc] initWithFrame:oscRect];
        _oscIcon.imageAlignment = NSImageAlignCenter;
        _oscIcon.image = [NSImage imageNamed:@"group_broadcast"];
        
        NSRect leaderRect = oscRect;
        leaderRect.origin.x -= leaderRect.size.width - 5;
        _leaderIcon = [[NSImageView alloc] initWithFrame:leaderRect];
        _leaderIcon.imageAlignment = NSImageAlignCenter;
        _leaderIcon.image = [NSImage imageNamed:@"group_broadcast"];
        
        [self addSubview:_infoBtn];
        [self addSubview:_oscIcon];
        [self addSubview:_leaderIcon];
        
        NSRect titRect = self.titleField.frame;
        titRect.size.width = _leaderIcon.frame.origin.x - titRect.origin.x - 5;
        self.titleField.frame = titRect;
    }
    
    return self;
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

    // Drawing code here.
    
    if ([self.dataSource isLeader]) {
        [self.leaderIcon setHidden:NO];
    }else{
        [self.leaderIcon setHidden:YES];
    }
    
    if ([self.dataSource isRunningOSC]) {
        [self.oscIcon setHidden:NO];
    }else{
        [self.oscIcon setHidden:YES];
    }
}


-(void)infoBtnClicked:(NSButton *)sender
{
    if([self.delegate respondsToSelector:@selector(infoBtnClickOnContentCellView:)]){
        [self.delegate infoBtnClickOnContentCellView:self];
    }
}

@end

