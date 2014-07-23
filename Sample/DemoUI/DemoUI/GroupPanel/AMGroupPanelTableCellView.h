//
//  AMGroupPanelTableCellView.h
//  DemoUI
//
//  Created by Wei Wang on 7/22/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AMGroupPanelTableCellView : NSTableCellView

@property (weak) id delegate;

-(void)doubleClicked:(id)sender;

@end
