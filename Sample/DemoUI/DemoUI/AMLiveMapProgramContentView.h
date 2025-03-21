//
//  AMLiveMapProgramScrollView.h
//  DemoUI
//
//  Created by Brad Phillips on 11/10/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMCoreData/AMCoreData.h"
#import <WebKit/WebKit.h>

@interface AMLiveMapProgramContentView : NSView

@property AMLiveGroup *group;
@property NSMutableDictionary *fonts;
@property double totalH;
@property double bottomMargin;
@property double indentMargin;
@property double labelWidth;

@property NSRect curSize;
 
@property WebView *liveVideoStream;
@property NSMutableArray *allFields;

- (void)fillContent:(AMLiveGroup *)theGroup;

@end
