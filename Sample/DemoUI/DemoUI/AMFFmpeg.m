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
                                cfgs.videoCodec,
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

@end
