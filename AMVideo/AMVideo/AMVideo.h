//
//  AMVideo.h
//  AMVideo
//
//  Created by robbin on 11/17/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AMVideo : NSObject

+ (instancetype)sharedInstance;

- (NSViewController *)getMixerUI;

- (void)startSyphon;
- (void)stopSyphon;

-(BOOL)isSyphonServerStarted;

@end
