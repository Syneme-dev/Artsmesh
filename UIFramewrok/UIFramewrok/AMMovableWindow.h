//
//  AMMovableWindow.h
//  UIFramewrok
//
//  Created by xujian on 4/2/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AMMovableWindow : NSWindow

@property(nonatomic, assign) NSPoint initialLocation;

//- (id)initWithContentRect:(NSRect)contentRect
//                styleMask:(NSUInteger)windowStyle
//                  backing:(NSBackingStoreType)bufferingType
//                    defer:(BOOL)deferCreation;
@end
