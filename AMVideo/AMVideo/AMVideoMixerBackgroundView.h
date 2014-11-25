//
//  AMVideoMixerBackgroundView.h
//  AMVideo
//
//  Created by robbin on 11/17/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AMVideoMixerBackgroundView : NSControl
@property (nonatomic) BOOL hasBorder;
@property (nonatomic) NSView *contentView;
@property (nonatomic) NSInteger clickCount;
@end
