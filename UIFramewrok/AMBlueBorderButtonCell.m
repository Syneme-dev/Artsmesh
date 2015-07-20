//
//  AMBlueBorderButtonCell.m
//  UIFramework
//
//  Created by KeysXu on 7/19/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMBlueBorderButtonCell.h"

@implementation AMBlueBorderButtonCell
//- (NSRect)drawTitle:(NSAttributedString *)title
//          withFrame:(NSRect)frame
//             inView:(NSView *)controlView {
//    
//    NSDictionary *attributes = [title attributesAtIndex:0 effectiveRange:nil];
//    
//    NSColor *systemDisabled = [NSColor colorWithCatalogName:@"System"
//                                                  colorName:@"disabledControlTextColor"];
//    NSColor *buttonTextColor = attributes[NSForegroundColorAttributeName];
//    
//    if (systemDisabled == buttonTextColor) {
//        NSMutableDictionary *newAttrs = [attributes mutableCopy];
//        newAttrs[NSForegroundColorAttributeName] = [NSColor orangeColor];
//        title = [[NSAttributedString alloc] initWithString:title.string
//                                                attributes:newAttrs];
//    }
//    
//    return [super drawTitle:title
//                  withFrame:frame
//                     inView:controlView];
//    
//}
- (BOOL)_textDimsWhenDisabled {
    return NO;
}

- (BOOL)_shouldDrawTextWithDisabledAppearance {
    return NO;
}


@end
