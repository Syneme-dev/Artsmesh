//
//  AMBlueBorderButton.m
//  UIFramework
//
//  Created by KeysXu on 5/17/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMBlueBorderButton.h"

#import "AMButtonHandler.h"

@implementation AMBlueBorderButton
-(void)viewWillDraw
{
//    [AMButtonHandler changeTabTextColor:self toColor:UI_Color_blue];
//    [self.layer setBorderWidth:1.0];
//    [self.layer setBorderColor: UI_Color_blue.CGColor];
    
//    self.layer.borderColor = UI_Color_blue.CGColor;
//    self.layer.borderWidth = 2.0;
    
}
//
- (void)drawRect:(NSRect)dirtyRect
{
    
            [super drawRect:dirtyRect];
    self.layer.borderColor = UI_Color_blue.CGColor;
    self.layer.borderWidth = 2.0;

    // Drawing code here.
    if(!self.enabled){
         [self.cell setBackgroundColor:UI_Color_b7b7b7_Disable];
    }
    else{
        
        [self.cell setBackgroundColor:[NSColor blackColor]];
    }

    [AMButtonHandler changeTabTextColor:self toColor:UI_Color_blue];
//    [self.cell setBorderColor:UI_Color_blue];
//    [self.cell setBorderWidth : 2.0f];

   
}


//- (instancetype)initWithFrame:(NSRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        [AMButtonHandler changeTabTextColor:self toColor:UI_Color_blue];
//        [self.layer setBorderWidth:1.0];
//        [self.layer setBorderColor: UI_Color_blue.CGColor];
//    }
//    return self;
//}
//- (instancetype)initWithCoder:(NSCoder *)coder
//{
//    self = [super initWithCoder:coder];
//    if (self) {
//        [AMButtonHandler changeTabTextColor:self toColor:UI_Color_blue];
//        [self.layer setBorderWidth:1.0];
//        [self.layer setBorderColor: UI_Color_blue.CGColor];
//
//    }
//    return self;
//}
//
//- (void)viewDidLoad {
////    [super viewDidLoad];
//    // Do view setup here.
//    
//   
//}


@end
