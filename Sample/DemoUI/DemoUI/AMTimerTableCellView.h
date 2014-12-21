//
//  AMTimerTableCellView.h
//  DemoUI
//
//  Created by robbin on 14/12/15.
//  Copyright (c) 2014年 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AMTimerTableCellView : NSTableCellView
@property (weak, nonatomic) IBOutlet NSComboBox *groupCombox;
@property (weak, nonatomic) IBOutlet NSComboBox *slowdownCombox;

@property (weak, nonatomic) IBOutlet NSTextField *metronomeLabel;
@property (weak, nonatomic) IBOutlet NSTextField *bpmLabel;
@property (weak, nonatomic) IBOutlet NSTextField *delayLabel;
@end
