//
//  AMCheckBoxView.h
//  CheckBoxTest
//
//  Created by Wei Wang on 7/14/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AMCheckBoxView : NSControl

@property NSString* title;
@property BOOL  checked;
@property NSFont* font;
@property NSColor* textColor;
@property NSColor* backgroupColor;
@property NSColor* btnBackGroundColor;
@property NSColor* btnColor;
@property BOOL readOnly;

@end
