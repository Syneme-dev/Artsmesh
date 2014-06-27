//
//  AMGroupOutlineRowView.h
//  AMGroupOutlineTest
//
//  Created by 王 为 on 6/27/14.
//  Copyright (c) 2014 王 为. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@protocol AMGroupOutlineRowViewDelegate;

@interface AMGroupOutlineRowView : NSTableRowView

@property id<AMGroupOutlineRowViewDelegate> delegate;

@end

@protocol AMGroupOutlineRowViewDelegate <NSObject>

-(NSImage*)headImageForRowView:(AMGroupOutlineRowView*)rowView;
-(NSImage*)alterHeadImageForRowView:(AMGroupOutlineRowView*)rowView;

@end
