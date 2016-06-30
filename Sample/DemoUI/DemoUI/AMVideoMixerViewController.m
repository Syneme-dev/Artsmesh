//
//  AMVideoMixerViewController.m
//  AMVideo
//
//  Created by robbin on 11/17/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import "AMVideoMixerViewController.h"
#import "AMVideoMixerBackgroundView.h"
#import "AMPanelViewController.h"
#import "UIFrameWork/AMPanelView.h"
#import "AMAppDelegate.h"
#import "AMSyphonView.h"
#import "AMSyphonCamera.h"
#import "VideoView.h"

@interface AMVideoMixerViewController ()
@property (weak) IBOutlet AMVideoMixerBackgroundView *bigView;
@property (weak) IBOutlet AMVideoMixerBackgroundView *smallView0;
@property (weak) IBOutlet AMVideoMixerBackgroundView *smallView1;
@property (weak) IBOutlet AMVideoMixerBackgroundView *smallView2;
@property (weak) IBOutlet AMVideoMixerBackgroundView *smallView3;
@property (weak) IBOutlet AMVideoMixerBackgroundView *smallView4;
@property (weak) IBOutlet AMVideoMixerBackgroundView *smallView5;
@property (weak) IBOutlet AMVideoMixerBackgroundView *smallView6;
@property (weak) IBOutlet AMVideoMixerBackgroundView *smallView7;
@property (weak) IBOutlet AMVideoMixerBackgroundView *smallView8;
@property (weak) IBOutlet AMVideoMixerBackgroundView *smallView9;
@property (strong, nonatomic, readonly) NSArray *smallViews;
@property (weak, nonatomic) AMVideoMixerBackgroundView *selected;

@property  (nonatomic) AMSyphonCamera* syCamera;
@end

@implementation AMVideoMixerViewController
@synthesize smallViews = _smallViews;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
    
    _syCamera = [[AMSyphonCamera alloc] init];
    [_syCamera initializeDevice];
}

- (void)setup
{
    self.bigView.hasBorder = YES;
    self.bigView.contentView = [self.syphonManager outputView];
    

    for (int i = 0; i < self.smallViews.count/2; i++) {
      //    for (int i = 0; i < self.smallViews.count; i++) {
//        AMSyphonView *subView = [[AMSyphonView alloc] initWithFrame:NSMakeRect(0, 0, 300, 300)];
        AMVideoMixerBackgroundView *view = self.smallViews[i];
        view.contentView = [self.syphonManager clientViewByIndex:i];
    }
    
    for (NSUInteger j = self.smallViews.count / 2; j < self.smallViews.count; j++) {
        
        //        AMSyphonView *subView = [[AMSyphonView alloc] initWithFrame:NSMakeRect(0, 0, 300, 300)];
        AMVideoMixerBackgroundView *view = self.smallViews[j];
        view.contentView = [self.p2pViewManager clientViewByIndex:(j-self.smallViews.count / 2)];
    }
}

- (AMSyphonManager *)syphonManager
{
    if (!_syphonManager) {
        _syphonManager = [[AMSyphonManager alloc] initWithClientCount:(int)self.smallViews.count/2];
    }
    return _syphonManager;
}

- (AMP2PViewManager *)p2pViewManager
{
    if (!_p2pViewManager) {
        _p2pViewManager = [[AMP2PViewManager alloc] initWithClientCount:(int)self.smallViews.count/2];
    }
    return _p2pViewManager;
}



- (NSArray *)smallViews
{
    if (!_smallViews) {
        _smallViews = @[
            self.smallView0,
            self.smallView1,
            self.smallView2,
            self.smallView3,
            self.smallView4,
            self.smallView5,
            self.smallView6,
            self.smallView7,
            self.smallView8,
            self.smallView9
        ];
    }
    return _smallViews;
}

- (IBAction)handleSelectEvent:(AMVideoMixerBackgroundView *)sender
{
    if (sender == self.bigView) {
        if (sender.clickCount == 2) {
            [self popupVideoMixingWindow];
        }
    }else if(sender.clickCount == 2 && (sender == self.smallView5 || sender == self.smallView6 ||
             sender == self.smallView7 || sender == self.smallView8 ||
             sender == self.smallView9)){
        
        //if([self.sender ])
        {
            [self popupP2PVideoMixingWindow];
        }
    }else {
        if (sender.clickCount == 1 && sender != self.selected) {
            self.selected.hasBorder = NO;
            self.selected = sender;
            self.selected.hasBorder = YES;
            int index = (int)[self.smallViews indexOfObjectIdenticalTo:self.selected];
            [self.syphonManager selectClient:index];
        }
    }
}

-(void) popupP2PVideoMixingWindow
{
    static NSString *panelId = @"AMP2PVideoMixingWindow";
    
    AMAppDelegate *appDelegate = (AMAppDelegate *)[NSApp delegate];
    NSMutableDictionary *panelControllers = appDelegate.mainWindowController.panelControllers;
    
    if (!panelControllers[panelId]) {
        AMPanelViewController *popupController =
        [[AMPanelViewController alloc] initWithNibName:@"AMPanelView" bundle:nil];
        popupController.panelId = panelId;
        panelControllers[panelId] = popupController;
        AMPanelView *panelView = (AMPanelView *)popupController.view;
        panelView.panelViewController = popupController;
        panelView.preferredSize = NSMakeSize(800, 600);
        panelView.initialSize = panelView.preferredSize;
        
        NSView *subview = [[VideoView alloc] init];
        subview.frame = NSMakeRect(0, 20, panelView.bounds.size.width, panelView.bounds.size.height - 16);
        [subview setTranslatesAutoresizingMaskIntoConstraints:NO];
        [panelView addSubview:subview];
        NSDictionary *views = @{ @"subview" : subview };
        [panelView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subview]|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        [panelView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[subview]-16-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        
        [popupController onTearClick:self];
        popupController.title = @"P2PMIXING";
        popupController.settingButton.hidden = YES;
        popupController.tearOffButton.hidden = YES;
        popupController.tabPanelButton.hidden = YES;
        popupController.maxSizeButton.hidden = YES;
    }

}

- (void)popupVideoMixingWindow
{
    static NSString *panelId = @"AMVideoMixingPopupPanel";
    
    AMAppDelegate *appDelegate = (AMAppDelegate *)[NSApp delegate];
    NSMutableDictionary *panelControllers = appDelegate.mainWindowController.panelControllers;
    
    if (!panelControllers[panelId]) {
        AMPanelViewController *popupController =
            [[AMPanelViewController alloc] initWithNibName:@"AMPanelView" bundle:nil];
        popupController.panelId = panelId;
        panelControllers[panelId] = popupController;
        AMPanelView *panelView = (AMPanelView *)popupController.view;
        panelView.panelViewController = popupController;
        panelView.preferredSize = NSMakeSize(800, 600);
        panelView.initialSize = panelView.preferredSize;
        
        NSView *subview = [self.syphonManager tearOffView];
        subview.frame = NSMakeRect(0, 20, panelView.bounds.size.width, panelView.bounds.size.height - 16);
        [subview setTranslatesAutoresizingMaskIntoConstraints:NO];
        [panelView addSubview:subview];
        NSDictionary *views = @{ @"subview" : subview };
        [panelView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subview]|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        [panelView addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[subview]-16-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        
        [popupController onTearClick:self];
        popupController.title = @"MIXING";
        popupController.settingButton.hidden = YES;
        popupController.tearOffButton.hidden = YES;
        popupController.tabPanelButton.hidden = YES;
        popupController.maxSizeButton.hidden = YES;
    }
}

@end
