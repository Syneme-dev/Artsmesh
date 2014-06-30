//
//  AMGroupOutlineLabelCellController.m
//  DemoUI
//
//  Created by 王 为 on 6/30/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMGroupOutlineLabelCellController.h"

@interface AMGroupOutlineLabelCellController ()

@end

@implementation AMGroupOutlineLabelCellController

-(void)updateUI
{
    NSTableCellView* cellView = (NSTableCellView*)self.view;
    
    if(self.labelText != nil){
        cellView.textField.stringValue = self.labelText;
    }else{
        cellView.textField.stringValue = @"Artsmesh";
    }
    
    [cellView.imageView setHidden:YES];
}

@end
