//
//  AMVolumeBar.m
//  AMAudio
//
//  Created by 王为 on 10/11/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMVolumeBar.h"

@implementation AMVolumeBar

@synthesize volume;
@synthesize isMute;

-(float)volume{
    return volume;
}

-(void)setVolume:(float)vol{
    
    [self willChangeValueForKey:@"volume"];
    volume = vol;

    if ([self.delegate respondsToSelector:@selector(volumeBarChanged:)]) {
        [self.delegate volumeBarChanged:self];
    }
    
    [self didChangeValueForKey:@"volume"];
}


-(BOOL)isMute
{
    return isMute;
}

-(void)setIsMute:(BOOL)mute
{
    [self willChangeValueForKey:@"isMute"];
    isMute = mute;
    
    if ([self.delegate respondsToSelector:@selector(volumeBarChanged:)]) {
        [self.delegate volumeBarChanged:self];
    }

    [self didChangeValueForKey:@"isMute"];

}


@end
