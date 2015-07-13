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
           }
    return self;
}


-(void)viewWillDraw
{

//    [self.layer setBorderWidth:1.0];
    [self.layer setBorderColor: UI_Color_b7b7b7.CGColor];
    
    // Drawing code here.
    if(!self.enabled){
      //  [self.layer setBorderWidth:1.0] ;
        // [self.layer setBorderColor: UI_Color_b7b7b7_Disable.CGColor];
          [self.cell setBackgroundColor:UI_Color_b7b7b7_Disable];
    }
    else{
        
        [self.layer setBorderWidth:1.0];
//        [self.cell setBackgroundColor:[NSColor whiteColor]];
    }
     [AMButtonHandler changeTabTextColor:self toColor:UI_Color_b7b7b7];
    
}
//

//Note:code for drawRect should not be moved.
//this makes the disable button in group details show correct.

-(void)drawRect:(NSRect)dirtyRect{
    [super drawRect:dirtyRect];
}




@end
