//
//  AMRouterView.h
//  Artsmesh
//
//  Created by WhiskyZed on 03/01/2017.
//  Copyright © 2017 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMChannel.h"
@class AMRouterView;


@protocol AMRouterViewDelegate

- (BOOL)routeView:(AMRouterView *)routeView
shouldConnectChannel:(AMChannel *)channel1
        toChannel:(AMChannel *)channel2;

- (BOOL)routeView:(AMRouterView *)routeView
   connectChannel:(AMChannel *)channel1
        toChannel:(AMChannel *)channel2;

- (BOOL)routeView:(AMRouterView *)routeView
shouldDisonnectChannel:(AMChannel *)channel1
      fromChannel:(AMChannel *)channel2;

- (BOOL)routeView:(AMRouterView *)routeView
disconnectChannel:(AMChannel *)channel1
      fromChannel:(AMChannel *)channel2;

- (BOOL)routeView:(AMRouterView *)routeView
shouldRemoveDevice:(NSString *)deviceID;

- (BOOL)routeView:(AMRouterView *)routeView
     removeDevice:(NSString *)deviceID;

- (BOOL)routeView:(AMRouterView *)routeView
  removeAllDevice:(BOOL)bCheck;

@end


@interface AMRouterView : NSView

@property(nonatomic) id<AMRouterViewDelegate> delegate;
@property(nonatomic, readonly) NSArray *allChannels;

- (void)associateChannels:(NSArray *)channels
               withDevice:(NSString *)deviceID
                     name:(NSString *)deviceName
                removable:(BOOL)removable;
- (AMChannel *)channelAtIndex:(NSUInteger)index;
- (NSArray *)channelsAssociatedWithDevice:(NSString *)deviceID;

- (void)connectChannel:(AMChannel *)channel1 toChannel:(AMChannel *)channel2;
- (void)disconnectChannel:(AMChannel *)channel1 fromChannel:(AMChannel *)channel2;
- (void)removeDevice:(NSString *)deviceID;
- (void)removeALLDevice;

+(NSUInteger)maxChannels;

@end


