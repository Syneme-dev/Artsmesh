//
//  AMTextFieldCell.m
//  UIFramework
//
//  Created by lattesir on 8/7/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMTextFieldCell.h"

@implementation AMTextFieldCell

- (NSText *)setUpFieldEditorAttributes:(NSText *)textObj
{
    NSTextView *textEditor = (NSTextView *)textObj;
    textEditor.backgroundColor = [NSColor colorWithCalibratedRed:(46)/255.0f green:(58)/255.0f blue:(75)/255.0f alpha:1.0f];
    textEditor.selectedTextAttributes = @{
        NSForegroundColorAttributeName : [NSColor lightGrayColor],
        NSBackgroundColorAttributeName : [NSColor darkGrayColor],
    };
    return textEditor;
}

@end
