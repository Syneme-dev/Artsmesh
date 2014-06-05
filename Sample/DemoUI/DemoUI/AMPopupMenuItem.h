//
//  AMPopupMenuItem.h
//  DemoUI
//
//  Created by Wei Wang on 5/7/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMETCDPreferenceViewController.h"
#import "AMMouseOverButtonView.h"

@interface AMPopupMenuItem : NSMenuItem

@property AMMouseOverButtonView *theLabel;

@property NSPopUpButton * popupButton;
-(id)initWithTitle:(NSString *)aString action:(SEL)aSelector keyEquivalent:(NSString *)charCode
             width:(CGFloat)width;


@end
