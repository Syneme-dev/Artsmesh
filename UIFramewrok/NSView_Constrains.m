//
//  NSView_Constrains.m
//  DemoUI
//
//  Created by 王为 on 19/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//


#import "NSView_Constrains.h"

@implementation NSView(Constrains)

+(void)addConstrains:(NSView *)superView
           toSubview:(NSView *)subView
        leadingSpace:(CGFloat)leading
       trailingSpace:(CGFloat)trailing
            topSpace:(CGFloat)top
         bottomSpace:(CGFloat)bottom
{
    NSString *hConstrain = [NSString stringWithFormat:@"H:|-%f-[subView]-%f-|", leading, trailing];
    NSString *vConstrain = [NSString stringWithFormat:@"V:|-%f-[subView]-%f-|", top, bottom];
    
    
    [superView addSubview:subView];
    [subView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *views = NSDictionaryOfVariableBindings(subView);
    [superView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:hConstrain
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    [superView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:vConstrain
                                             options:0
                                             metrics:nil
                                               views:views]];
}


+(void)addConstrains:(NSView *)superView
           toSubview:(NSView *)subView
        leadingSpace:(CGFloat)leading
               width:(CGFloat)width
            topSpace:(CGFloat)top
              height:(CGFloat)height
{
    NSString *hConstrain = [NSString stringWithFormat:@"H:|-%f-[subView(==%f)]", leading, width];
    NSString *vConstrain = [NSString stringWithFormat:@"V:|-%f-[subView(==%f)]", top, height];
    
    [superView addSubview:subView];
    [subView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *views = NSDictionaryOfVariableBindings(subView);
    [superView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:hConstrain
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    [superView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:vConstrain
                                             options:0
                                             metrics:nil
                                               views:views]];
}


+(void)addConstrains:(NSView *)superView
           toSubview:(NSView *)subView
               width:(CGFloat)width
       trailingSpace:(CGFloat)trailing
              height:(CGFloat)height
         bottomSpace:(CGFloat)bottom

{
    NSString *hConstrain = [NSString stringWithFormat:@"H:[subView(==%f)]-%f-|", width, trailing];
    NSString *vConstrain = [NSString stringWithFormat:@"V:[subView(==%f)]-%f-|", height, bottom];
    
    [superView addSubview:subView];
    [subView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSDictionary *views = NSDictionaryOfVariableBindings(subView);
    [superView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:hConstrain
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    [superView addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:vConstrain
                                             options:0
                                             metrics:nil
                                               views:views]];
}


-(void)addConstrainsToSubview:(NSView *)subview
                 leadingSpace:(CGFloat)leading
                trailingSpace:(CGFloat)trailing
                     topSpace:(CGFloat)top
                  bottomSpace:(CGFloat)bottom
{
    [NSView addConstrains:self
                toSubview:subview
             leadingSpace:leading
            trailingSpace:trailing
                 topSpace:top
              bottomSpace:bottom];
}


-(void)addFullConstrainsToSubview:(NSView *)subview
{
    [NSView addConstrains:self
                toSubview:subview
             leadingSpace:0
            trailingSpace:0
                 topSpace:0
              bottomSpace:0];
}

-(void)addConstrainsToFixSizeSubview:(NSView *)subview
                        leadingSpace:(CGFloat)leading
                               width:(CGFloat)width
                            topSpace:(CGFloat)top
                              height:(CGFloat)height

{
    [NSView addConstrains:self
                toSubview:subview
             leadingSpace:leading
                    width:width
                 topSpace:top
                   height:height];
}


-(void)addConstrainsToFixSizeSubview:(NSView *)subview
                               width:(CGFloat)width
                       trailingSpace:(CGFloat)trailing
                              height:(CGFloat)height
                         bottomSpace:(CGFloat)bottom
{
    [NSView addConstrains:self
                toSubview:subview
                    width:width
            trailingSpace:trailing
                   height:height
              bottomSpace:bottom ];

}


@end


