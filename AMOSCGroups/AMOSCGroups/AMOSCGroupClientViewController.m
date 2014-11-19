//
//  AMOSCGroupClientViewController.m
//  AMOSCGroups
//
//  Created by wangwei on 13/11/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import "AMOSCGroupClientViewController.h"
#import "AMOSCClient.h"
#import "AMOSCGroups.h"
#import "AMPreferenceManager/AMPreferenceManager.h"

@interface AMOSCGroupClientViewController ()

@property (weak) IBOutlet NSButton *oscStartBtn;
@end

@implementation AMOSCGroupClientViewController
{
    AMOSCClient* _oscClient;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    _oscClient = [[AMOSCClient alloc] init];

}

- (IBAction)starttest:(id)sender {
    if ([self.oscStartBtn.title isEqualTo:@"Start"]) {
        if([[AMOSCGroups sharedInstance] startOSCGroupClient]){
            self.oscStartBtn.title = @"Stop";
        }
    }else{
        [_oscClient stopOscClient];
        self.oscStartBtn.title = @"Start";
    }
}


@end
