//
//  AMStaticGroupOutlineCellViewController.m
//  DemoUI
//
//  Created by 王 为 on 7/10/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMStaticGroupOutlineCellViewController.h"

@interface AMStaticGroupOutlineCellViewController ()

@end

@implementation AMStaticGroupOutlineCellViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)updateUI
{
    NSTableCellView* cellView = (NSTableCellView*)self.view;
    [cellView.imageView setHidden:YES];
    cellView.textField.stringValue = [self.staticGroup nickname];
    
}


@end
