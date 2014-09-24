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

-(void)sortChannels
{
    NSMutableArray* sortedChannels = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.channels count]; i++) {
        
        AMChannel* chann = self.channels[i];
        if (chann.type == AMDestinationChannel) {
            [sortedChannels addObject:chann];
        }else{

            BOOL bFind = NO;
            for (int j = 0; j < [sortedChannels count]; j++) {
                AMChannel* existCh = sortedChannels[j];
                if (existCh.type == AMDestinationChannel) {
                    [sortedChannels insertObject:chann atIndex:j];
                    bFind = YES;
                    break;
                }
            }
            
            if (!bFind) {
                [sortedChannels addObject:chann];
            }
        }
    }
    
    self.channels = sortedChannels;
}

@end
