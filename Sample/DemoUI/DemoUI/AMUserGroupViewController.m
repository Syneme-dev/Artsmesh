//
//  AMUserGroupViewController.m
//  DemoUI
//
//  Created by Wei Wang on 4/1/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMUserGroupViewController.h"
#import "AMMesher/AMMesher.h"

@interface AMUserGroupViewController ()

@end

@implementation AMUserGroupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        self.sharedMesher  =  [AMMesher sharedAMMesher];
    
    }
    
    return self;
}


-(void)clearEveryThing
{
}

- (void)handleUserGroupChange:(NSArray *)userGroups {

}


@end
