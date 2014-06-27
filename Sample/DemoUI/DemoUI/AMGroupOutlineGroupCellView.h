//
//  AMGroupOutlineGroupCellView.h
//  AMGroupOutlineTest
//
//  Created by 王 为 on 6/27/14.
//  Copyright (c) 2014 王 为. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class AMFoundryFontView;

@interface AMGroupOutlineGroupCellView : NSTableCellView

@property (weak) IBOutlet NSButton *lockBtn;
@property (weak) IBOutlet NSButton *messageBtn;
@property (weak) IBOutlet NSButton *mergeBtn;
@property (weak) IBOutlet NSButton *leaveBtn;
@property (weak) IBOutlet NSButton *infoBtn;
@property (weak) IBOutlet AMFoundryFontView *descriptionField;

@end
