//
//  AMEventsManagerViewController.m
//  Artsmesh
//
//  Created by Brad Phillips on 5/7/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMEventsManagerViewController.h"

@interface AMEventsManagerViewController ()

@end

@implementation AMEventsManagerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)setTitle:(NSString *)theTitle {
    [self.feedbackTitleTextField setStringValue:theTitle];
}

@end
