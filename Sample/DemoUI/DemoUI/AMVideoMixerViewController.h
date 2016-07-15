//
//  AMVideoMixerViewController.h
//  AMVideo
//
//  Created by robbin on 11/17/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMSyphonManager.h"
#import "AMPanelViewController.h"

@interface AMVideoMixerViewController : NSViewController<AMActionDelegate>

@property (strong, nonatomic) AMSyphonManager*  syphonManager;
@property (strong, nonatomic) AMP2PViewManager* p2pViewManager;

@end
