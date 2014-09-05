//
//  AMRouteView.h
//  RoutePanel
//
//  Created by lattesir on 9/5/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class AMChannel;
@class AMRouteView;

@protocol AMRouterViewDelegate

- (BOOL)routeView:(AMRouteView *)routeView
shouldConnectChannel:(AMChannel *)channel1
        toChannel:(AMChannel *)channel2;
- (BOOL)routeView:(AMRouteView *)routeView
   connectChannel:(AMChannel *)channel1
        toChannel:(AMChannel *)channel2;

- (BOOL)routeView:(AMRouteView *)routeView
shouldDisonnectChannel:(AMChannel *)channel1
      fromChannel:(AMChannel *)channel2;
- (BOOL)routeView:(AMRouteView *)routeView
disconnectChannel:(AMChannel *)channel1
      fromChannel:(AMChannel *)channel2;

- (BOOL)routeView:(AMRouteView *)routeView
shouldRemoveDevice:(NSString *)deviceID;
- (BOOL)routeView:(AMRouteView *)routeView
     removeDevice:(NSString *)deviceID;

@end


@interface AMRouteView : NSView

@property(nonatomic) id<AMRouterViewDelegate> delegate;
@property(nonatomic, readonly) NSArray *allChannels;

- (void)associateSourceChannels:(NSIndexSet *)sourceChannelIndexes
            destinationChannels:(NSIndexSet *)destinationChannelIndexes
                     withDevice:(NSString *)deviceID
                           name:(NSString *)deviceName;
- (AMChannel *)channelAtIndex:(NSUInteger)index;
- (NSArray *)channelsAssociatedWithDevice:(NSString *)deviceID;

@end