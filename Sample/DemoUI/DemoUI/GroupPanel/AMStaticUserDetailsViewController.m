//
//  AMStaticUserDetailsViewController.m
//  DemoUI
//
//  Created by Wei Wang on 7/22/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMStaticUserDetailsViewController.h"
#import <UIFramework/AMFoundryFontView.h>

@interface AMStaticUserDetailsViewController ()
@property (weak) IBOutlet AMFoundryFontView *userName;
@property (weak) IBOutlet AMFoundryFontView *location;
@property (weak) IBOutlet AMFoundryFontView *timeZone;
@property (unsafe_unretained) IBOutlet NSTextView *homepage;
@property (unsafe_unretained) IBOutlet NSTextView *description;

@end

@implementation AMStaticUserDetailsViewController

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
    if (self.homepage && self.staticUser.url) {
        NSFont* textViewFont =  [NSFont fontWithName: @"FoundryMonoline-Bold" size: self.homepage.font.pointSize];
        NSDictionary* attr = @{NSForegroundColorAttributeName: [NSColor whiteColor],
                               NSFontAttributeName:textViewFont};
        NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:self.staticUser.url attributes:attr];
        [self.homepage.textStorage appendAttributedString:attrStr];
        [self.homepage setNeedsDisplay:YES];
    }
    
    if (self.description && self.staticUser.description) {
        NSFont* textViewFont =  [NSFont fontWithName: @"FoundryMonoline-Bold" size: self.description.font.pointSize];
        NSDictionary* attr = @{NSForegroundColorAttributeName: [NSColor whiteColor],
                               NSFontAttributeName:textViewFont};
        NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString:self.staticUser.description attributes:attr];
        [self.description.textStorage appendAttributedString:attrStr];
        [self.description setNeedsDisplay:YES];
    }
}

@end
