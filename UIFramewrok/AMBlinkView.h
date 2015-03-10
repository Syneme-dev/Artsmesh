//
//  AMBlinkView.h
//  UIFramework
//
//  Created by whiskyzed on 3/7/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@protocol AMBlinkViewDelegate;

@interface AMBlinkView : NSImageView

- (instancetype) init;

- (BOOL)  setBlinkImage :  (NSImage*) image
         alternateImage :  (NSImage*) alterImage;

- (BOOL) setBlinkMaxCount : (int)   count
            timerInterval : (float) interval;

- (void) startBlink;

@property id<AMBlinkViewDelegate> blinkDelegate;
@end




@protocol AMBlinkViewDelegate <NSObject>

@optional
- (BOOL) shouldStop;
- (void) afterStopBlink;

@end