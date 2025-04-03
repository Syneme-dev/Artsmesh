//
//  AMAudioDevice.m
//  AMAudio
//
//  Created by 王 为 on 8/22/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMAudioDevice.h"

@implementation AMAudioDevice

-(BOOL)isAggregateDevice
{
    // Disable this function.
    return NO;
    
    if(self.inChannels >0 && self.outChanels > 0){
        return YES;
    }
    
    return NO;
}

@end
