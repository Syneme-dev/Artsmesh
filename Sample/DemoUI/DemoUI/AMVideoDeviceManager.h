//
//  AMVideoDeviceManager.h
//  Artsmesh
//
//  Created by Whisky Zed on 162/26/.
//  Copyright © 2016年 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMChannel.h"

@interface AMVideoDeviceManager : NSObject

@property NSMutableArray*     videoChannels;
@property NSMutableArray*     peerDevices;
@property AMVideoDevice*      myselfDevice;
@property AMChannel*          nilChannel;

+(id)sharedInstance;

-(int) findFirstIndex;
-(NSInteger) findFirstMyselfIndex :(AMVideoDevice*) v;

-(NSArray*)  allServerDevices;
@end
