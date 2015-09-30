//
//  AMManualViewController.m
//  DemoUI
//
//  Created by Wei Wang on 8/11/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMManualViewController.h"

@interface AMManualViewController ()<NSOutlineViewDataSource>
@property (weak) IBOutlet NSOutlineView *outlineView;

@end

@implementation AMManualViewController

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
    self.outlineView.dataSource = self;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if (item == nil) {
        return 1;
    }else{
        return 0;
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    long i =  [self outlineView:outlineView numberOfChildrenOfItem:item];
    return i > 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    NSString* str;
    if (item == nil) {
        if (index == 0) {
            str = @"QUICK START";
        }else if(index == 1){
            str = @"Live Group Over View";
        }else if(index == 2){
            str = @"Live User Over View";
        }
        return str;
    }else{
        return nil;
    }
}


@end
