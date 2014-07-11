//
//  AMTabPanelViewController.m
//  DemoUI
//
//  Created by xujian on 7/9/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMTabPanelViewController.h"

@interface AMTabPanelViewController ()

@end

@implementation AMTabPanelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)awakeFromNib{
    [self registerTabButtons];
}


-(void)registerTabButtons{
}
-(void)selectTabIndex:(NSInteger)index{
    [self.tabs selectTabViewItemAtIndex:index];
}

@end
