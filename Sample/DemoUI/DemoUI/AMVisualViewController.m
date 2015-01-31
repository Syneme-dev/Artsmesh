//
//  AMVisualViewController.m
//  DemoUI
//
//  Created by xujian on 6/9/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMVisualViewController.h"
#import "AMAudio/AMAudio.h"
#import <UIFramework/AMButtonHandler.h>
#import "AMOSCGroups/AMOSCGroups.h"


@interface AMVisualViewController ()
@property (strong) IBOutlet NSView *contentView;
@property (weak) IBOutlet NSButton *audioBtn;

@end

@implementation AMVisualViewController
{
    NSViewController* _audioRouterViewController;
}

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
    [super awakeFromNib];
    [AMButtonHandler changeTabTextColor:self.audioBtn toColor:UI_Color_b7b7b7];
    
    [self loadAudioRouterView: self.contentView];
}

-(void)loadTabViews
{

}

-(void)loadAudioRouterView:(NSView*)tabView
{
    _audioRouterViewController = [[AMAudio sharedInstance] getJackRouterUI];
    if (_audioRouterViewController) {
        NSView* contentView = _audioRouterViewController.view;
        contentView.frame = NSMakeRect(0, 0, 800, 600);
        [tabView addSubview:contentView];
        
        [contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSDictionary *views = NSDictionaryOfVariableBindings(contentView);
        [tabView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[contentView]-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        [tabView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[contentView]-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];

    }
}

@end
