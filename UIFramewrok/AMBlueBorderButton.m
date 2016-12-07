//
//  AMBlueBorderButton.m
//  UIFramework
//
//  Created by KeysXu on 5/17/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMBlueBorderButton.h"
#import <QuartzCore/QuartzCore.h>

#import "AMButtonHandler.h"

@implementation AMBlueBorderButton

- (instancetype)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(changeTheme:)
                                                     name:@"AMThemeChanged"
                                                   object:nil];
        
        self.curTheme = [AMTheme sharedInstance];
        self.textColor = self.curTheme.colorBorder;
        
        [AMButtonHandler changeTabTextColor:self toColor:[NSColor whiteColor]];
        [self.cell setImageDimsWhenDisabled:NO];
           }
    return self;
}


-(void)viewWillDraw
{
    self.curTheme = [AMTheme sharedInstance];
    self.textColor = self.curTheme.colorBorder;
    
    [self.layer setBorderWidth:1.0];
    /**
    [self.layer setBorderColor: UI_Color_b7b7b7.CGColor];
 [AMButtonHandler changeTabTextColor:self toColor:UI_Color_b7b7b7];
    NSLog(@"btn border color: %@",self.textColor.CGColor);
    **/
    [self.layer setBorderColor:self.textColor.CGColor];
    [AMButtonHandler changeTabTextColor:self toColor:self.textColor];
    // Drawing code here.
    if(!self.enabled){
//        [self.layer setBorderWidth:1.0] ;
//         [self.layer setBorderColor: UI_Color_b7b7b7_Disable.CGColor];
//                  [self.cell setBackgroundColor:UI_Color_b7b7b7_Disable];
    }
    else{
        [self.layer setBorderWidth:1.0];
//        [AMButtonHandler changeTabTextColor:self toColor:UI_Color_b7b7b7];
    }
    
}
//

//Note:code for drawRect should not be moved.
//this makes the disable button in group details show correct.

-(void)drawRect:(NSRect)dirtyRect{
    [super drawRect:dirtyRect];
}

- (void) changeTheme:(NSNotification *) notification {
    //Update text properties
    self.curTheme = [AMTheme sharedInstance];
    
    self.textColor = _curTheme.colorText;
    [self setNeedsDisplay:YES];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
