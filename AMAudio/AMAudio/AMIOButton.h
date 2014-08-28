//
//  AMIOButton.h
//  RouterPanel
//
//  Created by Brad Phillips on 8/21/14.
//  Copyright (c) 2014 Detao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMConnectionLine.h"

@interface AMIOButton : NSButton

@property (weak) AMIOButton *connectedTo;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) int butWidth;
@property (nonatomic, assign) int butHeight;

- (id)initWithFrame:(CGRect)frame andSize:(int) butSize;
- (void)makeButtonConnected:(AMIOButton *) theButton;
- (void)resetButton:(AMIOButton *) theButton;

@end
