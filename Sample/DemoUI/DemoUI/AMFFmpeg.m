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
    
    NSString *_curPidCheck;
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
                                @"%@ -s %@ -f avfoundation -r %@ -i \"%@:none\" -vcodec %@ -b:v %@ -an -f mpegts -threads 8 udp://%@:%@",
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

-(void)checkExistingPIDs {
    //NSLog(@"checking existing PIDs now.");
    _curPidCheck = nil;
    
    // This function will check if stored PIDs are still in use & clear out the dead
    NSDictionary *currentStreams = [[AMPreferenceManager standardUserDefaults] objectForKey:Preference_Key_ffmpeg_Cur_P2P];
    
    for (NSString *PID in currentStreams) {
        [self executePIDCheck:[currentStreams objectForKey:PID]];
    }
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
    // Got PID from ffmpeg task
    // Next, parse the data, pull it out and store
    
    NSFileHandle *outputFile = (NSFileHandle *) [notification object];
    NSData *data = [outputFile availableData];
        
    if([data length]) {
        //Parsing PID from returned data
        NSString *temp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSArray *pidLines=[temp componentsSeparatedByString:@"\n"];
        
        //Load up current streams from preferences
        NSMutableDictionary *currentStreams = [[[AMPreferenceManager standardUserDefaults] objectForKey:Preference_Key_ffmpeg_Cur_P2P] mutableCopy];
        //NSLog(@"existing connections preferences: %@", currentStreams);
        
        //Insert new IP & PID into the dictionary
        NSString *serverAddr = _configs.serverAddr;
        NSString *fullAddr = [NSString stringWithFormat:@"%@:%@", serverAddr, [self getPort:_configs.portOffset]];
        //[currentStreams setObject:fullAddr forKey:pidLines[0]];
        [currentStreams setObject:pidLines[0] forKey:fullAddr];
        
        //Store the updated dictionary
        [[AMPreferenceManager standardUserDefaults] setObject:currentStreams forKey:Preference_Key_ffmpeg_Cur_P2P];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //NSLog(@"Updated connections preferences: %@", [[AMPreferenceManager standardUserDefaults] objectForKey:Preference_Key_ffmpeg_Cur_P2P]);
        
    }
}
- (BOOL) stopAllFFmpegInstances:(NSArray*) processes{
    if ([processes count] <= 0) {
        return NO;
    }
    NSMutableString* command = nil;
    for(int i = 0; i < [processes count]; i++){
        if (i == 0) {
            command = [NSMutableString stringWithFormat:
                                        @"kill %@ ", [processes objectAtIndex:i]];
        }
        [command appendFormat:@"%@ ",[processes objectAtIndex:i]];
    }
    
    NSLog(@"Stopping ffmpeg instance with PID of %@", command);
    
    /** Execute the NSTask to kill the specific ffmpeg instance by PID*/

    
    _stopFFMpegTask = nil;
    _stopFFMpegTask = [[NSTask alloc] init];
    _stopFFMpegTask.launchPath = @"/bin/bash";
    _stopFFMpegTask.arguments = @[@"-c", [command copy]];
    _stopFFMpegTask.terminationHandler = ^(NSTask* t){
    };
    //   sleep(2);
    
    [_stopFFMpegTask launch];
    
    /** Update stored prefs to remove said instance using the PID key **/
    for (NSString* processID in processes) {
        [self removeProcessFromPrefs:processID];
    }
    
     return YES;
}

-(BOOL)stopFFmpegInstance: (NSString *)processID {
    NSLog(@"Stopping ffmpeg instance with PID of %@", processID);
    /** Execute the NSTask to kill the specific ffmpeg instance by PID **/
    NSMutableString *command = [NSMutableString stringWithFormat:
                                @"kill %@",processID];
    _stopFFMpegTask = nil;
    _stopFFMpegTask = [[NSTask alloc] init];
    _stopFFMpegTask.launchPath = @"/bin/bash";
    _stopFFMpegTask.arguments = @[@"-c", [command copy]];
    _stopFFMpegTask.terminationHandler = ^(NSTask* t){
        
    };
 //   sleep(2);
    
    [_stopFFMpegTask launch];
    
    /** Update stored prefs to remove said instance using the PID key **/
    [self removeProcessFromPrefs:processID];
    
    return YES;
}

-(BOOL)stopFFmpeg {
    [[AMPreferenceManager standardUserDefaults] setObject:nil forKey:Preference_Key_ffmpeg_Cur_P2P];
    
    NSMutableString *command = [NSMutableString stringWithFormat:
                                @"killall ffmpeg"];
    _stopFFMpegTask = nil;
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

//PID Check Stuff
-(void)executePIDCheck: (NSString *)PID {
    //NSLog(@"executing PID check for process: %@", PID);
    _curPidCheck = PID;
    NSPipe *pipe = [NSPipe pipe];
    
    NSFileHandle *file = pipe.fileHandleForReading;
    [file waitForDataInBackgroundAndNotify];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pidCheckResults:) name:NSFileHandleDataAvailableNotification object:file];
    
    NSMutableString *command = [NSMutableString stringWithFormat:
                                @"ps -p %@", PID];
    _pidTask = [[NSTask alloc] init];
    _pidTask.launchPath = @"/bin/bash";
    _pidTask.arguments = @[@"-c", [command copy]];
    _pidTask.terminationHandler = ^(NSTask* t){
        
    };
    
    [_pidTask setStandardOutput:pipe];
    [_pidTask setStandardError: [_pidTask standardOutput]];
    
    [_pidTask launch];
    [_pidTask waitUntilExit];
}
-(void)pidCheckResults : (NSNotification *)notification {
    //Got results from PID check
    NSFileHandle *outputFile = (NSFileHandle *) [notification object];
    NSData *data = [outputFile availableData];
    
    if([data length]) {
        //parse data to look for current PID we're checking
        NSString *temp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSString *errorMsg = @"Invalid process id";
        
        // If PID isn't found in response or an error message is found, remove that pref
        if ([temp rangeOfString:_curPidCheck].location == NSNotFound || [temp rangeOfString:errorMsg].location != NSNotFound) {
            //process no longer running, kill it from prefs
            [self removeProcessFromPrefs:_curPidCheck];
        } else {
            //process found!
        }
    }
}

-(void)removeProcessFromPrefs: (NSString *)PID {
    NSMutableDictionary *currentStreams = [[[AMPreferenceManager standardUserDefaults] objectForKey:Preference_Key_ffmpeg_Cur_P2P] mutableCopy];
    
    //[currentStreams removeObjectForKey:_curPidCheck];
    NSArray *processesToRemove = [currentStreams allKeysForObject:PID];
    for (NSString *processKey in processesToRemove) {
        [currentStreams removeObjectForKey:processKey];
    }
    
    [self updateCurStreamPrefs:currentStreams];
}
-(void)updateCurStreamPrefs: (NSMutableDictionary *)currentStreams {
    //Store the updated dictionary
    [[AMPreferenceManager standardUserDefaults] setObject:currentStreams forKey:Preference_Key_ffmpeg_Cur_P2P];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"Updated connections preferences: %@", [[AMPreferenceManager standardUserDefaults] objectForKey:Preference_Key_ffmpeg_Cur_P2P]);
}

@end
