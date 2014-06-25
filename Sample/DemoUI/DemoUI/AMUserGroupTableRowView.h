//
//  AMUserGroupTableRowView.h
//  DemoUI
//
//  Created by Wei Wang on 6/24/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@protocol AMUserGroupTableRowViewDelegate;

@interface AMUserGroupTableRowView : NSTableRowView

@property (weak)id<AMUserGroupTableRowViewDelegate> delegate;

@end

@protocol AMUserGroupTableRowViewDelegate <NSObject>

-(void)userGroupTableRowView:(AMUserGroupTableRowView*)rowView
                 headerImage:(NSImage**)image
              alternateImage:(NSImage**)alterImage;

@end
