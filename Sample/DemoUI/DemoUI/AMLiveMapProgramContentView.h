//
//  AMLiveMapProgramScrollView.h
//  DemoUI
//
//  Created by Brad Phillips on 11/10/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMCoreData/AMCoreData.h"

@interface AMLiveMapProgramContentView : NSView

@property AMLiveGroup *group;
@property NSScrollView *theScrollView;
@property NSMutableDictionary *fonts;
@property double totalH;
@property double bottomMargin;
@property double indentMargin;

- (void)fillContent:(AMLiveGroup *)theGroup inScrollView:(NSScrollView *)scrollView;

@end
