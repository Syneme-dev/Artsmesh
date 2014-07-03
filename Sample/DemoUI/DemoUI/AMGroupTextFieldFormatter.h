//
//  AMGroupTextFieldFormatter.h
//  DemoUI
//
//  Created by Wei Wang on 7/3/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMGroupTextFieldFormatter : NSFormatter

- (void)setMaximumLength:(int)len;
- (int)maximumLength;

@end
