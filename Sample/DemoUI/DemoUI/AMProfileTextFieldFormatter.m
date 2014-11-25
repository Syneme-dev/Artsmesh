//
//  AMProfileTextFieldFormatter.m
//  DemoUI
//
//  Created by Brad Phillips on 11/21/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#define _TRACE

#import "AMProfileTextFieldFormatter.h"

@implementation AMProfileTextFieldFormatter

@synthesize maxLength = _maxLength;

- (id)init
{
    if(self = [super init]){
        self.maxLength = INT_MAX;
    
        NSLog(@"max length is: %i", self.maxLength);
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    // support Nib based initialisation
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.maxLength = INT_MAX;
    }
    
    return self;
}

#pragma mark -
#pragma mark Textual Representation of Cell Content

- (NSString *)stringForObjectValue:(id)object
{
    NSString *stringValue = nil;
    if ([object isKindOfClass:[NSString class]]) {
        
        // A new NSString is perhaps not required here
        // but generically a new object would be generated
        stringValue = [NSString stringWithString:object];
    }
    
    return stringValue;
}

#pragma mark -
#pragma mark Object Equivalent to Textual Representation

- (BOOL)getObjectValue:(id *)object forString:(NSString *)string errorDescription:(NSString **)error
{
    BOOL valid = YES;
    
    // Be sure to generate a new object here or binding woe ensues
    // when continuously updating bindings are enabled.
    *object = [NSString stringWithString:string];
    
    return valid;
}

#pragma mark -
#pragma mark Dynamic Cell Editing

- (BOOL)isPartialStringValid:(NSString **)partialStringPtr
proposedSelectedRange:(NSRangePointer)proposedSelRangePtr
originalString:(NSString *)origString
originalSelectedRange:(NSRange)origSelRange
errorDescription:(NSString **)error
{
    BOOL valid = YES;
    
    NSString *proposedString = *partialStringPtr;
    if ([proposedString length] > self.maxLength) {
        
        // The original string has been modified by one or more characters (via pasting).
        // Either way compute how much of the proposed string can be accommodated.
        NSInteger origLength = origString.length;
        NSInteger insertLength = self.maxLength - origLength;
        
        // If a range is selected then characters in that range will be removed
        // so adjust the insert length accordingly
        insertLength += origSelRange.length;
        
        // Get the string components
        NSString *prefix = [origString substringToIndex:origSelRange.location];
        NSString *suffix = [origString substringFromIndex:origSelRange.location + origSelRange.length];
        NSString *insert = [proposedString substringWithRange:NSMakeRange(origSelRange.location, insertLength)];
        
#ifdef _TRACE
        
        NSLog(@"Original string: %@", origString);
        NSLog(@"Original selection location: %lu length %lu", (unsigned long)origSelRange.location, (unsigned long)origSelRange.length);
        
        NSLog(@"Proposed string: %@", proposedString);
        NSLog(@"Proposed selection location: %lu length %lu", (unsigned long)proposedSelRangePtr->location, (unsigned long)proposedSelRangePtr->length);
        
        NSLog(@"Prefix: %@", prefix);
        NSLog(@"Suffix: %@", suffix);
        NSLog(@"Insert: %@", insert);
#endif
        
        // Assemble the final string
        *partialStringPtr = [NSString stringWithFormat:@"%@%@%@", prefix, insert, suffix];
        
        // Fix-up the proposed selection range
        proposedSelRangePtr->location = origSelRange.location + insertLength;
        proposedSelRangePtr->length = 0;
        
#ifdef _TRACE
        
        NSLog(@"Final string: %@", *partialStringPtr);
        NSLog(@"Final selection location: %lu length %lu", (unsigned long)proposedSelRangePtr->location, (unsigned long)proposedSelRangePtr->length);
        
#endif
        valid = NO;
    }
    
    return valid;
}

@end