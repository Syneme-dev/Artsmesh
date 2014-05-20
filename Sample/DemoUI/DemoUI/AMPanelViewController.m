//
//  AMPanelViewController.m
//  DemoUI
//
//  Created by xujian on 3/6/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMPanelViewController.h"

@interface AMPanelViewController ()

@end

@implementation AMPanelViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        // Initialization code here.
    }
   

    return self;
}

-(void)awakeFromNib
{
     [self.titleView setFont: [NSFont fontWithName: @"FoundryMonoline-Medium" size: self.titleView.font.pointSize]];
}

-(void)setTitle:(NSString *)title{
    [self.titleView setStringValue:title];
}

- (IBAction)closePanel:(id)sender {
    [self.view setHidden:YES];
    //TODO:move right panel to left.
//    NSPoint point=NSMakePoint(self.view.frame.origin.x+100.0, self.view.frame.origin.y);
//    [self.view setFrameOrigin:point];
    
}
@end
