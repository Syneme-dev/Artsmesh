//
//  AMGroupPanelTableCellController.h
//  DemoUI
//
//  Created by Wei Wang on 7/22/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AMCoreData/AMCoreData.h>

@interface AMGroupPanelTableCellController : NSViewController

@property NSMutableArray* childrenController;

-(void)updateUI;
-(void)setTrackArea;
-(void)removeTrackAres;
-(void)cellViewDoubleClicked:(id)sender;

@end
