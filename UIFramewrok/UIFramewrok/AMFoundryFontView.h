//
//  AMFoundryFontView.h
//  UIFramewrok
//
//  Created by xujian on 4/27/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMTheme.h"

@interface AMFoundryFontView : NSTextField

@property (strong) NSColor *curFontTextColor;
@property (strong) AMTheme *curTheme;

-(void)setFontSize:(CGFloat)size;
-(void)changeTheme:(NSNotification *)notification;


@end
