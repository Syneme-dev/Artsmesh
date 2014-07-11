//
//  AMStaticGroupOutlineCellView.h
//  DemoUI
//
//  Created by Wei Wang on 7/11/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AMStaticGroupOutlineCellView : NSTableCellView

@property (weak) IBOutlet NSButton *socialBtn;
@property (weak) id delegate;
@property (weak) IBOutlet NSButton *infoBtn;

@end
