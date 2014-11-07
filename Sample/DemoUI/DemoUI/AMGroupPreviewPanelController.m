//
//  AMGroupPreviewPanelController.m
//  DemoUI
//
//  Created by Brad Phillips on 11/6/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMGroupPreviewPanelController.h"

@interface AMGroupPreviewPanelController ()

@end

@implementation AMGroupPreviewPanelController

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
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    
    NSFont *italic = [fontManager fontWithFamily:@"FoundryMonoline-RegItalic" traits:NSUnitalicFontMask weight:5 size:20.0];
    
    [self.descriptionTextField setFont:italic];
}

@end
