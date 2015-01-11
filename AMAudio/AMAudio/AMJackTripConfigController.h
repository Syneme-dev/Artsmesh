//
//  AMJackTripConfigController.h
//  AMAudio
//
//  Created by Wei Wang on 9/5/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMJackTripManager.h"
#import "AMJackManager.h"

@interface AMJackTripConfigController : NSViewController

@property (weak)AMJackTripManager* jacktripManager;
@property (weak)AMJackManager* jackManager;
@property (weak)NSPopover* owner;
@property int maxChannels;


@end
