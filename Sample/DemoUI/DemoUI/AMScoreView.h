//
//  AMScoreView.h
//  Artsmesh
//
//  Created by whiskyzed on 3/23/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AMScoreView : NSView

- (void) addMusicScore : (NSImage*) image;
- (void) removeMusicScore;

static void AMScoreViewCommonInit(AMScoreView* scoreView);
@end
