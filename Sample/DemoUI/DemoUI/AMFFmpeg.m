//
//  AMFFmpeg.m
//  Artsmesh
//
//  Created by Brad Phillips on 1/26/16.
//  Copyright © 2016 Artsmesh. All rights reserved.
//

#import "AMFFmpeg.h"
#import "AMPreferenceManager/AMPreferenceManager.h"

@implementation AMFFmpeg {
    NSTask *_ffmpegTask;
    NSTask *_pidTask;
    NSTask *_stopFFMpegTask;
    NSBundle *_mainBundle;
    NSString *_launchPath;
    AMFFmpegConfigs *_configs;
    
}

-(id)init {
    if (self = [super init]) {
        //Set up initial configs here
        _mainBundle = [NSBundle mainBundle];
        
    }

    return self;
}
-(void)setLaunchPath:(AMFFmpegConfigs *)cfgs {
    NSString *program = @"ffmpeg";
    if (!cfgs.sending) { program = @"ffplay"; }
    _launchPath =[_mainBundle pathForAuxiliaryExecutable:program];
    _launchPath = [NSString stringWithFormat:@"\"%@\"",_launchPath];
}

-(BOOL)sendP2P:(AMFFmpegConfigs *)cfgs {
    [self setLaunchPath:cfgs];
    _configs = cfgs;

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
    //NSLog(@"%@", command);
    
    if (![self launchTask:command andLogPID:YES]) {
        return NO;
    } else { return YES; }
}

-(BOOL)receiveP2P:(AMFFmpegConfigs *)cfgs {
    [self setLaunchPath:cfgs];
    _configs = cfgs;
    
    NSMutableString *command = [NSMutableString stringWithFormat:
                                @"%@ udp://%@:%@",
                                _launchPath,
                                cfgs.serverAddr,
                                [self getPort:cfgs.portOffset]];
    //NSLog(@"%@", command);
    
    if (![self launchTask:command andLogPID:YES]) {
        return NO;
    } else { return YES; }
}

-(BOOL)launchTask:(NSString *)theCommand andLogPID:(BOOL)logPID{
    
    _ffmpegTask = [[NSTask alloc] init];
    _ffmpegTask.launchPath = @"/bin/bash";
    _ffmpegTask.arguments = @[@"-c", [theCommand copy]];
    _ffmpegTask.terminationHandler = ^(NSTask* t){
        
    };
    sleep(2);
    [_ffmpegTask setStandardInput:[NSPipe pipe]];
    
    [_ffmpegTask launch];
    
    if (logPID) {
        [self getTaskPID:@"ffmpeg"];
    }
    
    return YES;
}

-(void)getTaskPID : (NSString *)label {
    NSPipe *pipe = [NSPipe pipe];
    
    NSFileHandle *file = pipe.fileHandleForReading;
    [file waitForDataInBackgroundAndNotify];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotTaskPID:) name:NSFileHandleDataAvailableNotification object:file];
    
    NSMutableString *command = [NSMutableString stringWithFormat:
                                @"pgrep -n %@", label];
    _pidTask = [[NSTask alloc] init];
    _pidTask.launchPath = @"/bin/bash";
    _pidTask.arguments = @[@"-c", [command copy]];
    _pidTask.terminationHandler = ^(NSTask* t){
        
    };
    //sleep(2);
    
    [_pidTask setStandardOutput:pipe];
    [_pidTask setStandardError: [_pidTask standardOutput]];
    
    [_pidTask launch];
    [_pidTask waitUntilExit];
    
}

-(void)gotTaskPID : (NSNotification *)notification {
    NSLog(@"got task PID!");
    
    NSFileHandle *outputFile = (NSFileHandle *) [notification object];
    NSData *data = [outputFile availableData];
        
    if([data length]) {
        //PID Returned, grab it and store in standard default
        //Parse PID from returned data
        NSString *temp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSArray *pidLines=[temp componentsSeparatedByString:@"\n"];
        //NSLog(@"Storing PID %@", tempPID);
        
        //Load up current streams from preferences
        NSMutableDictionary *currentStreams = [[[AMPreferenceManager standardUserDefaults] objectForKey:Preference_Key_ffmpeg_Cur_P2P] mutableCopy];
        NSLog(@"existing connections preferences: %@", currentStreams);
        
        //Insert new IP & PID into the dictionary
        NSString *serverAddr = _configs.serverAddr;
        [currentStreams setObject:pidLines[0] forKey:serverAddr];
        
        //Store the updated dictionary
        [[AMPreferenceManager standardUserDefaults] setObject:currentStreams forKey:Preference_Key_ffmpeg_Cur_P2P];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSLog(@"Updated connections preferences: %@", [[AMPreferenceManager standardUserDefaults] objectForKey:Preference_Key_ffmpeg_Cur_P2P]);
        
    }
}

-(BOOL)stopFFmpeg {
    //[[AMPreferenceManager standardUserDefaults] setObject:nil forKey:Preference_Key_ffmpeg_Cur_P2P];
    
    NSMutableString *command = [NSMutableString stringWithFormat:
                                @"killall ffmpeg"];
    _stopFFMpegTask = [[NSTask alloc] init];
    _stopFFMpegTask.launchPath = @"/bin/bash";
    _stopFFMpegTask.arguments = @[@"-c", [command copy]];
    _stopFFMpegTask.terminationHandler = ^(NSTask* t){
        
    };
    sleep(2);
    
    [_stopFFMpegTask launch];
    
    return YES;
}

// Make FFMPEG call to find AVFoundation Devices on machine
-(NSFileHandle *)populateDevicesList {
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSPipe *pipe = [NSPipe pipe];
    NSFileHandle *file = pipe.fileHandleForReading;
    
    NSString* launchPath =[mainBundle pathForAuxiliaryExecutable:@"ffmpeg"];
    launchPath = [NSString stringWithFormat:@"\"%@\"",launchPath];
    
    
    NSMutableString *command = [NSMutableString stringWithFormat:
                                @"%@ -f avfoundation -list_devices true -i \"\"",
                                launchPath];
    _ffmpegTask = [[NSTask alloc] init];
    _ffmpegTask.launchPath = @"/bin/bash";
    _ffmpegTask.arguments = @[@"-c", [command copy]];
    _ffmpegTask.terminationHandler = ^(NSTask* t){
        
    };
    
    [_ffmpegTask setStandardOutput:pipe];
    [_ffmpegTask setStandardError: [_ffmpegTask standardOutput]];
    
    [_ffmpegTask launch];
    
    return file;
}

-(BOOL)streamToYouTube:(AMFFmpegConfigs *)cfgs {
    NSBundle* mainBundle = [NSBundle mainBundle];
    
    NSString* launchPath =[mainBundle pathForAuxiliaryExecutable:@"ffmpeg"];
    launchPath = [NSString stringWithFormat:@"\"%@\"",launchPath];
    
    NSMutableString *command = [NSMutableString stringWithFormat:
                                @"%@ -f avfoundation -r %@ -i \"%@:%@\" -pix_fmt yuyv422 -vcodec libx264 -b:v %@k -preset fast -acodec %@ -b:a %@k -ar %@ -s %@ -threads 0 -f flv \"%@/%@\"",
                                launchPath,
                                cfgs.videoFrameRate,
                                cfgs.videoDevice,
                                cfgs.audioDevice,
                                cfgs.videoBitRate,
                                cfgs.audioCodec,
                                cfgs.audioBitRate,
                                cfgs.audioSampleRate,
                                cfgs.videoOutSize,
                                cfgs.serverAddr,
                                cfgs.streamName];
    //NSLog(@"%@", command);
    _ffmpegTask = [[NSTask alloc] init];
    _ffmpegTask.launchPath = @"/bin/bash";
    _ffmpegTask.arguments = @[@"-c", [command copy]];
    _ffmpegTask.terminationHandler = ^(NSTask* t){
        
    };
    sleep(2);
    
    [_ffmpegTask launch];
    
    return YES;
}

/** Internal Class Functions **/
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
