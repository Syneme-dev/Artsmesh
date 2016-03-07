//
//  AMRouteView.h
//  RoutePanel
//
//  Created by lattesir on 9/5/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class AMChannel;
@class AMVideoRouteView;

@protocol AMVideoRouterViewDelegate

- (BOOL)routeView:(AMVideoRouteView *)routeView
shouldConnectChannel:(AMChannel *)channel1
        toChannel:(AMChannel *)channel2;
- (BOOL)routeView:(AMVideoRouteView *)routeView
   connectChannel:(AMChannel *)channel1
        toChannel:(AMChannel *)channel2;

- (BOOL)routeView:(AMVideoRouteView *)routeView
shouldDisonnectChannel:(AMChannel *)channel1
      fromChannel:(AMChannel *)channel2;
- (BOOL)routeView:(AMVideoRouteView *)routeView
disconnectChannel:(AMChannel *)channel1
      fromChannel:(AMChannel *)channel2;

- (BOOL)routeView:(AMVideoRouteView *)routeView
shouldRemoveDevice:(NSString *)deviceID;
- (BOOL)routeView:(AMVideoRouteView *)routeView
     removeDevice:(NSString *)deviceID;

- (BOOL)routeView:(AMVideoRouteView *)routeView
  removeAllDevice:(BOOL)bCheck;

@end


@interface AMVideoRouteView : NSView

@property(nonatomic) id<AMVideoRouterViewDelegate> delegate;
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