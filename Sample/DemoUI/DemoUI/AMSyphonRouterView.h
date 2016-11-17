//
//  AMRouteView.h
//  RoutePanel
//
//  Created by lattesir on 9/5/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UIFramework/AMTheme.h"
#import "AMVideoRouteView.h"

@class AMChannel;
@class AMSyphonRouterView;

@protocol AMSyphonRouterViewDelegate

- (BOOL)routeView:(AMSyphonRouterView *)routeView
shouldConnectChannel:(AMChannel *)channel1
        toChannel:(AMChannel *)channel2;
- (BOOL)routeView:(AMSyphonRouterView *)routeView
   connectChannel:(AMChannel *)channel1
        toChannel:(AMChannel *)channel2;

- (BOOL)routeView:(AMSyphonRouterView *)routeView
shouldDisonnectChannel:(AMChannel *)channel1
      fromChannel:(AMChannel *)channel2;
- (BOOL)routeView:(AMSyphonRouterView *)routeView
disconnectChannel:(AMChannel *)channel1
      fromChannel:(AMChannel *)channel2;

- (BOOL)routeView:(AMSyphonRouterView *)routeView
shouldRemoveDevice:(NSString *)deviceID;
- (BOOL)routeView:(AMSyphonRouterView *)routeView
     removeDevice:(NSString *)deviceID;

- (BOOL)routeView:(AMSyphonRouterView *)routeView
  removeAllDevice:(BOOL)bCheck;

@end


@interface AMSyphonRouterView : AMVideoRouteView

@property(nonatomic) id<AMSyphonRouterViewDelegate> delegate;
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
