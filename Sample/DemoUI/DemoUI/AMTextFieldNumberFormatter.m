//
//  AMTextFieldNumberFormatter.m
//  Artsmesh
//
//  Created by Brad Phillips on 4/27/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMTextFieldNumberFormatter.h"

@implementation AMTextFieldNumberFormatter

- (id)init {
    
    if(self = [super init]){
        
        maxLength = INT_MAX;
    }
    
    return self;
}

- (void)setMaximumLength:(int)len {
    maxLength = len;
}

- (int)maximumLength {
    return maxLength;
}

- (NSString *)stringForObjectValue:(id)object {
    return (NSString *)object;
}

- (BOOL)getObjectValue:(id *)object forString:(NSString *)string errorDescription:(NSString **)error {
    *object = string;
    return YES;
}

- (BOOL)isPartialStringValid:(NSString **)partialStringPtr
       proposedSelectedRange:(NSRangePointer)proposedSelRangePtr
              originalString:(NSString *)origString
       originalSelectedRange:(NSRange)origSelRange
            errorDescription:(NSString **)error {
    if ([*partialStringPtr length] > maxLength) {
        return NO;
    }
    
    if (![*partialStringPtr isEqual:[*partialStringPtr uppercaseString]]) {
        *partialStringPtr = [*partialStringPtr uppercaseString];
        return NO;
    }
    
    return YES;
}

- (NSAttributedString *)attributedStringForObjectValue:(id)anObject withDefaultAttributes:(NSDictionary *)attributes {
    return nil;
}

@end
