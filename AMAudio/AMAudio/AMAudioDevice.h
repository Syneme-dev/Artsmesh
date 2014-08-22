//
//  AMAudioDevice.h
//  AMAudio
//
//  Created by 王 为 on 8/22/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreAudio/CoreAudio.h>

@interface AMAudioDevice : NSObject

@property AudioDeviceID devId;
@property NSString* devUID;
@property NSString* devName;
@property int inChannels;
@property int outChanels;
@property NSMutableArray* sampleRates;
@property NSMutableArray* bufferSizes;

-(BOOL)isAggregateDevice;

@end
