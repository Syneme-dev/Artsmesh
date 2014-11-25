//
//  AMProfileTextFieldFormatter.h
//  DemoUI
//
//  Created by Brad Phillips on 11/21/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMProfileTextFieldFormatter : NSFormatter
{
    NSInteger _maxLength;
}

@property NSInteger maxLength;

@end