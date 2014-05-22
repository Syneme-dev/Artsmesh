//
//  AMBoxItem.h
//  BoxLayout2
//
//  Created by lattesir on 5/20/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMBoxItem : NSView<NSDraggingSource>

@property(nonatomic) CGFloat paddingLeft;
@property(nonatomic) CGFloat paddingRight;
@property(nonatomic) CGFloat paddingTop;
@property(nonatomic) CGFloat paddingBottom;
@property(nonatomic) NSSize minSizeConstraint;
@property(nonatomic) NSSize maxSizeConstraint;
@property(nonatomic) BOOL draggingSource;
@property(nonatomic, readonly) BOOL visiable;

- (void)setPadding:(CGFloat)padding;


@end