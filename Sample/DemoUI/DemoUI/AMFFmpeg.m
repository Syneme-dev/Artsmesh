//
//  AMFFmpeg.m
//  Artsmesh
//
//  Created by Brad Phillips on 1/26/16.
//  Copyright © 2016 Artsmesh. All rights reserved.
//

#import "AMFFmpeg.h"

@implementation AMFFmpeg {
    NSTask *_ffmpegTask;
    NSBundle *_mainBundle;
    NSString *_launchPath;
    
}

-(id)init {
    if (self = [super init]) {
        //Set up initial configs here
        _mainBundle = [NSBundle mainBundle];
        
        _launchPath =[_mainBundle pathForAuxiliaryExecutable:@"ffmpeg"];
        _launchPath = [NSString stringWithFormat:@"\"%@\"",_launchPath];
        
    }

    return self;
}

-(BOOL)sendP2P:(AMFFmpegConfigs *)cfgs {

    NSMutableString *command = [NSMutableString stringWithFormat:
                                @"%@ -s %@ -f avfoundation -r %@ -i \"%@:0\" -vcodec %@ -b:v %@ -an -f mpegts -threads 8 udp://%@:%@",
                                _launchPath,
                                cfgs.videoOutSize,
                                cfgs.videoFrameRate,
                                cfgs.videoDevice,
                                [self getCodec:cfgs],
                                cfgs.videoBitRate,
                                cfgs.serverAddr,
                                [self getPort:cfgs.portOffset]];
    NSLog(@"%@", command);
    _ffmpegTask = [[NSTask alloc] init];
    _ffmpegTask.launchPath = @"/bin/bash";
    _ffmpegTask.arguments = @[@"-c", [command copy]];
    _ffmpegTask.terminationHandler = ^(NSTask* t){
        
    };
    sleep(2);
    
    [_ffmpegTask launch];
    
    return YES;
}

-(NSString *)getPort:(NSString *)thePortOffset {
    int portOffset = (int) [thePortOffset integerValue];
    int port = 5564 + portOffset;
    
    return [NSString stringWithFormat:@"%d", port];
}

-(NSString *)getCodec:(AMFFmpegConfigs *)cfgs {
    int frameRateInt = (int) [cfgs.videoFrameRate integerValue];
    int maxRateInt = frameRateInt * 100;
    int maxSizeInt = frameRateInt * 50;
    int bufSizeInt = maxRateInt / frameRateInt;
    
    NSString *vCodec = [NSString stringWithFormat:@"libx264 -preset ultrafast -tune zerolatency -x264opts crf=20:vbv-maxrate=%d:vbv-bufsize=%d:intra-refresh=1:slice-max-size=%d:keyint=%d:ref=1", maxRateInt, bufSizeInt, maxSizeInt, frameRateInt];
    NSString *selectedCodec = cfgs.videoCodec;
    if ([selectedCodec isEqualToString:@"mpeg2"]) {
        vCodec = @"mpeg2video";
    }
    
    return vCodec;
}

@end
