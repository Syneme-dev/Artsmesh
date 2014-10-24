//
//  AMTabPanelViewController.m
//  DemoUI
//
//  Created by xujian on 7/9/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMTabPanelViewController.h"

#define kBlueColor [NSColor colorWithCalibratedRed:(46)/255.0f green:(58)/255.0f blue:(75)/255.0f alpha:1.0f]

@interface AMTabPanelViewController ()

@end

@implementation AMTabPanelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(void)awakeFromNib{
    [self registerTabButtons];
}


-(void)registerTabButtons{
}
-(void)selectTabIndex:(NSInteger)index{
    [self.tabs selectTabViewItemAtIndex:index];
}

- (void)pushDownButton:(NSButton *)button
{
    static NSFont *buttonFont = nil;
    static NSColor *buttonColor = nil;
    static NSColor *pushedDownButtonColor = nil;
    
    if (!buttonFont) {
        buttonFont = [NSFont fontWithName: @"FoundryMonoline-Medium"
                                     size: button.font.pointSize];
        buttonColor = [NSColor colorWithCalibratedRed:(46)/255.0f
                                                green:(58)/255.0f
                                                 blue:(75)/255.0f
                                                alpha:1.0f];
        pushedDownButtonColor = [NSColor lightGrayColor];
    }
    
    if (self.currentPushedDownButton == button)
        return;
    
    NSDictionary *attributes = @{
        NSFontAttributeName : buttonFont,
        NSForegroundColorAttributeName : buttonColor
    };
    
    if (self.currentPushedDownButton) {
        NSAttributedString *attributedTitle =
            [[NSAttributedString alloc] initWithString:self.currentPushedDownButton.title
                                            attributes:attributes];
        self.currentPushedDownButton.attributedTitle = attributedTitle;
    }
    
    self.currentPushedDownButton = button;
    NSMutableAttributedString *attributedTitle =
        [[NSMutableAttributedString alloc] initWithString:button.title];
    [attributedTitle setAttributes:attributes
                             range:NSMakeRange(0, button.title.length)];
    [attributedTitle addAttribute:NSForegroundColorAttributeName
                            value:pushedDownButtonColor
                            range:[self calculateTextRange:button.title]];
    button.attributedTitle = attributedTitle;
}

- (NSRange)calculateTextRange:(NSString *)title
{
    const char *cString = [title cStringUsingEncoding:NSUTF8StringEncoding];
    int len = (int)title.length;
    NSRange range = { 0, 0 };
    for (int i = 0; i < len; i++) {
        if (cString[i] != ' ') {
            range.location = i;
            break;
        }
    }
    for (int i = len - 1; i > range.location; i--) {
        if (cString[i] != ' ' && cString[i] != '|') {
            range.length = i - range.location + 1;
            break;
        }
    }
    return range;
}

@end
