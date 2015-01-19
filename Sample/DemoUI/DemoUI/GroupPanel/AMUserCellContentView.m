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
        
        self.leaderIcon = [self setFirstIconWithImage:
                           [NSImage imageNamed:@"group_leader"]];
        
        self.oscIcon = [self setSecondIconWithImage:
                        [NSImage imageNamed:@"group_oscIcon"]];
        
        self.infoBtn = [self setThirdBtnWithImage:
                        [NSImage imageNamed:@"usergroup_info"]];
        
        [self.infoBtn setTarget:self];
        [self.infoBtn setAction:@selector(infoBtnClicked:)];
        
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

