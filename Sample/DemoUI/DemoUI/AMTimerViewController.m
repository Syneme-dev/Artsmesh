//
//  AMTimerViewController.m
//  DemoUI
//
//  Created by xujian on 6/26/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMTimerViewController.h"
#import "UIFramework/AMFoundryFontView.h"
#import "AMTimer/AMTimer.h"

@interface AMTimerViewController ()
@property (weak) IBOutlet NSButton *timerBtn;
@property (weak) IBOutlet AMFoundryFontView *timerScreen;

@end

@implementation AMTimerViewController

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
    [[AMTimer shareInstance] addTimerScreen:self.timerScreen];
    
    [[AMTimer shareInstance] addObserver:self
                              forKeyPath:@"state"
                                 options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                                 context:nil];
}

-(void)dealloc
{
    [[AMTimer shareInstance] removeObserver:self forKeyPath:@"state"];
}

- (IBAction)timerBtnClicked:(NSButton *)sender
{
    if (sender.state == NSOnState) {
        [[AMTimer shareInstance] start];
    }
    else {
        
        [[AMTimer shareInstance] pause];
        [[AMTimer shareInstance] reset];
    }
}


#pragma mark -
#pragma   mark KVO
- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context
{
    if ([object isKindOfClass:[AMTimer class]]){
        
        if ([keyPath isEqualToString:@"state"]){
            AMTimerState newState = [[change objectForKey:@"new"] intValue];
            
            switch (newState) {
                case kAMTimerStart:
                    [self.timerBtn setState:1];
                    break;
                default:
                    [self.timerBtn setState:0];
                    break;
            }
        }
    }
}


@end
