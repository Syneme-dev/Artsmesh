//
//  AMOSCMessageViewController.m
//  DemoUI
//
//  Created by xujian on 6/25/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMOSCMessageViewController.h"
#import "AMOSCGroups/AMOSCGroups.h"
#import <UIFramework/AMButtonHandler.h>
#import <UIFramework/AMFoundryFontView.h>
#import "AMOSCGroups/AMOSCGroups.h"

@interface AMOSCMessageViewController ()
@property (weak) IBOutlet NSButton *clearBtn;
@property (weak) IBOutlet NSButton *searchBtn;
@property (weak) IBOutlet AMFoundryFontView *searchField;

@end

@implementation AMOSCMessageViewController
{
    NSViewController* _controller;
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
    [AMButtonHandler changeTabTextColor:self.clearBtn toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.searchBtn toColor:UI_Color_blue];
    
    _controller = [[AMOSCGroups sharedInstance] getOSCMonitorUI];
    if (_controller != nil) {
        NSView* contentView = _controller.view;
        [self.view addSubview:_controller.view];
        NSRect rect = self.view.bounds;
        
        rect.size.height -= 21;
        _controller.view.frame = rect;
        
        [contentView setTranslatesAutoresizingMaskIntoConstraints:NO];
        NSDictionary *views = NSDictionaryOfVariableBindings(contentView);
        [self.view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[contentView]-0-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
        
        [self.view addConstraints:
         [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-21-[contentView]-0-|"
                                                 options:0
                                                 metrics:nil
                                                   views:views]];
    }
}

- (IBAction)clearBtnClick:(id)sender
{
    self.searchField.stringValue = @"";
    [self.searchField resignFirstResponder];
    [[AMOSCGroups sharedInstance] setOSCMessageSearchFilterString:@""];
}

- (IBAction)searchBtnClick:(id)sender
{
    [self.searchField resignFirstResponder];
    [[AMOSCGroups sharedInstance] setOSCMessageSearchFilterString:self.searchField.stringValue];
}

- (IBAction)filterEntered:(id)sender
{
    [self.searchBtn performClick:nil];
}

-(void)cancelOperation:(id)sender
{
    [self.clearBtn performClick:nil];
}

@end
