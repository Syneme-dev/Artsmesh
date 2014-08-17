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

@property NSString* nodeItemIdentifier;;
@property NSMutableArray* childrenNodeItem;
@property BOOL isExpanded;

-(void)updateUI;
-(void)setTrackArea;
-(void)removeTrackAres;
-(void)cellViewDoubleClicked:(id)sender;

@end
