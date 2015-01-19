//
//  AMLocalGroupCellContentView.m
//  DemoUI
//
//  Created by 王为 on 19/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMLocalGroupCellContentView.h"

@implementation AMLocalGroupCellContentView


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
        
        NSRect broadcastRect = infoBtnRect;
        broadcastRect.origin.x -= infoBtnRect.size.width * 2;
        _broadcastIcon = [[NSImageView alloc] initWithFrame:broadcastRect];
        _broadcastIcon.imageAlignment = NSImageAlignCenter;
        _broadcastIcon.image = [NSImage imageNamed:@"group_broadcast"];
        
        [self addSubview:_infoBtn];
        [self addSubview:_broadcastIcon];
        
        NSRect titRect = self.titleField.frame;
        titRect.size.width = _broadcastIcon.frame.origin.x - titRect.origin.x - 5;
        self.titleField.frame = titRect;
    }
    
    return self;
}


- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
    if([self.dataSource isBroadcasting]){
        [self.broadcastIcon setHidden:NO];
    }else{
        [self.broadcastIcon setHidden:YES];
    }
}


-(void)infoBtnClicked:(NSButton *)sender
{
    if([self.delegate respondsToSelector:@selector(infoBtnClickOnContentCellView:)]){
        [self.delegate infoBtnClickOnContentCellView:self];
    }
}

@end
