//
//  AMTextFieldNumberFormatter.h
//  Artsmesh
//
//  Created by Brad Phillips on 4/27/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMTextFieldNumberFormatter : NSFormatter {
    int maxLength;
}

- (void)setMaximumLength:(int)len;
- (int)maximumLength;

@end
