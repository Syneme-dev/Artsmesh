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

- (IBAction)goOnline:(id)sender
{
    if ([[self.onlineButton title] isEqualToString:@"Online"])
    {
        [self.sharedMesher goOnline];
        [self.onlineButton setTitle:@"Offline"];
    }
    else if([[self.onlineButton title] isEqualToString:@"Offline"])
    {
        [self.sharedMesher goOffline];
        [self.onlineButton setTitle:@"Online"];
    }
    
}
@end
