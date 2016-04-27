//
//  AMFFmpegConfigs.h
//  AMAudio
//
//  Created by Brad Phillips on 1/18/16.
//  Copyright © 2016 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMFFmpegConfigs : NSObject

//Run in Sender Mode (using ffmpeg command)
//Run in Receiver Mode (using stream receiver program - ffplay/mplayer/etc)
@property NSString *role;

//                                  if client ip address
@property NSString *serverAddr;
@property NSString *ipv6Addr;
@property NSString *streamName;     // Sets stream name for YouTube streaming

//                                  Receiving port offset from base port 5564
@property NSString *portOffset;

/** Video Settings **/
// -i "1:0"                         Sets video input source - "[video]:[audio]" will be an integer value
@property NSString *videoDevice;
// -s "1920x1080"                   Initial scale for incoming input video data
@property NSString *videoInSize;
// -s "1280x720"                    Scale for outgoing video data
@property NSString *videoOutSize;
// -vcodec libx264                  Sets the encoding format for video data
@property NSString *videoFormat;
// -r 30                            Sets frame rate for video data
@property NSString *videoFrameRate;
// -b:v 800k                        Sets bit rate for video data
/** Properties relating to latency and key-framing **/
@property NSString *videoBitRate;
@property NSString *videoMaxRate;
@property NSString *videoBufSize;
@property NSString *videoMaxSize;
@property NSString *videoCodec;

/** Audio Settings **/
// -i "0:1"                         Sets audio input source - "[video]:[audio]" will be an integer value
@property NSString *audioDevice;
// -acodec aac                      Sets the encoding format for audio data
@property NSString *audioFormat;
// -ar 44100                        Sets the audio sample rate for audio data
@property NSString *audioSampleRate;
// -b:v 64k                         Sets the audio bit rate for audio data
@property NSString *audioBitRate;
@property NSString *audioCodec;

@property (nonatomic, assign) BOOL sending;

@end
