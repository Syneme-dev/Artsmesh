//
//  AMVideoDeviceManager.m
//  Artsmesh
//
//  Created by Whisky Zed on 162/26/.
//  Copyright © 2016年 Artsmesh. All rights reserved.
//

#import "AMVideoDeviceManager.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "AMFFmpeg.h"

@implementation AMVideoDeviceManager


+(instancetype)sharedInstance
{
    static AMVideoDeviceManager* sharedInstance = nil;
    @synchronized(self) {
        if(sharedInstance == nil){
            sharedInstance = [[self alloc] init];
        }
    }
    
    return sharedInstance;
}


-(instancetype)init
{
    if (self = [super init]) {
        _videoChannels = [[NSMutableArray alloc] init];
        _peerDevices   = [[NSMutableArray alloc] init];
        _myselfDevice  = [[AMVideoDevice  alloc] init];
        
        NSMutableArray* channels = [[NSMutableArray alloc] init];
        _nilChannel = [[AMChannel alloc] init];
        _nilChannel.deviceID     = @"";
        _nilChannel.channelName  = @"";
        
        for(int i = 0; i < 9; i++){
            _nilChannel.index = i;
            [channels addObject:_nilChannel];
        }
        
        _myselfDevice.channels = channels;
    }
    
    return self;
}


-(int) findFirstIndex
{
    BOOL find;
    
    for (int index = START_INDEX; index <= LAST_INDEX; index += INDEX_INTERVAL) {
        find = NO;
        for (AMVideoDevice* device in _peerDevices) {
            if (device.index == index) {
                find = YES;
                break;
            }
        }
        if (find == NO) {
            return index;
        }
    }
    
    return -1;
}

-(NSInteger) findFirstMyselfIndex :(AMVideoDevice*) v
{
    if ([_peerDevices indexOfObject:v] == NSNotFound) {
        return NSNotFound;
    }
    
    NSUInteger accumulativeIndex = 0;
    for (int i = 0 ; i < [_peerDevices count]; i++) {
        AMVideoDevice* device = [_peerDevices objectAtIndex:i];
        if(![device isEqual:v] && device.index < v.index){
            accumulativeIndex++;
        }
    }
    for (int index = START_INDEX; index <= v.index; index += INDEX_INTERVAL) {
        bool find = NO;
        for (AMVideoDevice* device in _peerDevices) {
            if (device.index == index) {
                find = YES;
                break;
            }
        }
        if (find == NO) {
             accumulativeIndex++;
        }
    }

    
    return accumulativeIndex;
}

@end
