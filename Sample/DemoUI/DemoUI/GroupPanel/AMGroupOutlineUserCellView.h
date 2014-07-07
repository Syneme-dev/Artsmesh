//
//  AMGroupOutlineUserCellView.h
//  AMGroupOutlineTest
//
//  Created by 王 为 on 6/27/14.
//  Copyright (c) 2014 王 为. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AMGroupOutlineUserCellView : NSTableCellView
@property (weak) IBOutlet NSButton *leaderBtn;
@property (weak) IBOutlet NSButton *zombieBtn;
@property (weak) IBOutlet NSButton *infoBtn;
@property (weak) IBOutlet NSTextField *descriptionField;

@end
