//
//  AMJackDevice.m
//  AMAudio
//
//  Created by 王 为 on 9/8/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMJackDevice.h"
#import "AMChannel.h"

@implementation AMJackDevice

-(BOOL)addDeviceToRouteView :(AMRouteView*)routeView
{
    NSUInteger myChanNum = [self.srcChans count] + [self.desChans count];
    
    NSArray* allChannels = routeView.allChannels;
    NSUInteger i = 0;
    for (; i < [allChannels count]; i++) {
        AMChannel* chann = allChannels[i];
        if (chann.type == AMPlaceholderChannel) {
            break;
        }
    }

    if (myChanNum > [AMRouteView maxChannels] - i) {
        NSLog(@"reach the max channels!");
        return NO;
    }
    
    NSMutableIndexSet* srcChannels = [[NSMutableIndexSet alloc] init];
    NSMutableIndexSet* desChannels = [[NSMutableIndexSet alloc] init];
    
    for (AMChannel* chann in self.srcChans) {
        [srcChannels addIndex:i];
        chann.index = i;
        i++;
    }
    
    for(AMChannel* chann in self.desChans){
        [desChannels addIndex:i];
        chann.index = i;
        i++;
    }
    
//    [routeView associateSourceChannels:srcChannels
//                   destinationChannels:desChannels
//                            withDevice:self.deviceID
//                                  name:self.deviceName];
    return YES;
}

@end
