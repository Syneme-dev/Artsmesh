//
//  AMLiveEventCheckBoxView.h
//  Artsmesh
//
//  Created by Brad Phillips on 5/9/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "UIFramework/AMCheckBoxView.h"
#import "GTLYouTube.h"

@interface AMLiveEventCheckBoxView : AMCheckBoxView

@property (strong) GTLYouTubeLiveBroadcast *liveBroadcast;

@end
