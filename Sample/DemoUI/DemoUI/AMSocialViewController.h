//
//  AMSocialViewController.h
//  DemoUI
//
//  Created by xujian on 4/18/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>


@interface AMSocialViewController : NSViewController
@property (strong) IBOutlet WebView *socialWebTab;

-(void)loadPage;

@end
