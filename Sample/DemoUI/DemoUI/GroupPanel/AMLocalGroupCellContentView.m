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
        self.infoBtn = [self setThirdBtnWithImage:
                        [NSImage imageNamed:@"usergroup_info"]];
        
        [self.infoBtn setTarget:self];
        [self.infoBtn setAction:@selector(infoBtnClicked:)];
        
        self.broadcastIcon = [self setFirstIconWithImage:
                              [NSImage imageNamed:@"group_broadcast"]];
        
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
