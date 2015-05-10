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
        self.ipv6Icon = [self setThirdIconWithImage:
                         [NSImage imageNamed:@"ipv6"]];
        
        [self.infoBtn setTarget:self];
        [self.infoBtn setAction:@selector(infoBtnClicked:)];
        
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
        //TODO:uncomment the following code when the AMLiveUser has a field ipv4/6 .
//        if ([self.dataSource isIPv6]) {
    if (true) {
        [self.ipv6Icon setHidden:NO];
    }else{
        [self.ipv6Icon setHidden:YES];
    }
}


-(void)infoBtnClicked:(NSButton *)sender
{
    if([self.delegate respondsToSelector:@selector(infoBtnClickOnContentCellView:)]){
        [self.delegate infoBtnClickOnContentCellView:self];
    }
}

@end

