//
//  NSView_Constrains.h
//  DemoUI
//
//  Created by 王为 on 19/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (Constrains)

-(void)addFullConstrainsToSubview:(NSView *)subview;

-(void)addConstrainsToSubview:(NSView *)subview
                 leadingSpace:(CGFloat)leading
                trailingSpace:(CGFloat)trailing
                     topSpace:(CGFloat)top
                  bottomSpace:(CGFloat)bottom;


-(void)addConstrainsToFixSizeSubview:(NSView *)subview
                        leadingSpace:(CGFloat)leading
                               width:(CGFloat)width
                            topSpace:(CGFloat)top
                              height:(CGFloat)height;

-(void)addConstrainsToFixSizeSubview:(NSView *)subview
                               width:(CGFloat)width
                       trailingSpace:(CGFloat)trailing
                              height:(CGFloat)height
                         bottomSpace:(CGFloat)bottom;


+(void)addConstrains:(NSView *)superView
           toSubview:(NSView *)subView
        leadingSpace:(CGFloat)leading
       trailingSpace:(CGFloat)trailing
            topSpace:(CGFloat)top
         bottomSpace:(CGFloat)bottom;

+(void)addConstrains:(NSView *)superView
           toSubview:(NSView *)subView
               width:(CGFloat)width
       trailingSpace:(CGFloat)trailing
              height:(CGFloat)height
         bottomSpace:(CGFloat)bottom;

+(void)addConstrains:(NSView *)superView
           toSubview:(NSView *)subView
        leadingSpace:(CGFloat)leading
               width:(CGFloat)width
            topSpace:(CGFloat)top
              height:(CGFloat)height;

@end
