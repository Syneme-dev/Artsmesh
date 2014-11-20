//
//  AMVideoMixerViewController.m
//  AMVideo
//
//  Created by robbin on 11/17/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import "AMVideoMixerViewController.h"
#import "AMVideoMixerBackgroundView.h"
#import "AMSyphonManager.h"

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
@property (strong, nonatomic) AMSyphonManager *syphonManager;
@end

@implementation AMVideoMixerViewController
@synthesize smallViews = _smallViews;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setup];
}

- (void)setup
{
    self.bigView.hasBorder = YES;
    self.bigView.contentView = [self.syphonManager getRouterView];
    for (int i = 0; i < self.smallViews.count; i++) {
        AMVideoMixerBackgroundView *view = self.smallViews[i];
        view.contentView = [self.syphonManager getViewByIndex:i];
    }
}

- (AMSyphonManager *)syphonManager
{
    if (!_syphonManager) {
        _syphonManager = [[AMSyphonManager alloc] initWithClientCount:(int)self.smallViews.count];
    }
    return _syphonManager;
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

- (void)mouseDown:(NSEvent *)theEvent
{
    NSPoint point = [self.view convertPoint:theEvent.locationInWindow
                                   fromView:nil];
    NSView *hitView = [self.view hitTest:point];
    if ([self.smallViews indexOfObjectIdenticalTo:hitView] != NSNotFound) {
        AMVideoMixerBackgroundView *theView = (AMVideoMixerBackgroundView *)hitView;
        if (!theView.hasBorder) {
            for (AMVideoMixerBackgroundView *view in self.smallViews) {
                if (view.hasBorder)
                    view.hasBorder = NO;
            }
            theView.hasBorder = YES;
        }
    }
}

@end
