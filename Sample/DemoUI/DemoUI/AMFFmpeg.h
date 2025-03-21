//
//  AMFFmpeg.h
//  Artsmesh
//
//  Created by Brad Phillips on 1/26/16.
//  Copyright © 2016 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMFFmpegConfigs.h"

@interface AMFFmpeg : NSObject

extern NSString * const AMVIDEOP2PNotification;
extern NSString * const AMVIDEOYouTubeStreamNotification;

-(BOOL)sendP2P:(AMFFmpegConfigs *)cfgs;
-(BOOL)receiveP2P:(AMFFmpegConfigs *)cfgs;
-(BOOL)streamToYouTube:(AMFFmpegConfigs *)cfgs;
-(NSFileHandle *)populateDevicesList;
-(void)checkExistingPIDs;
-(BOOL)stopFFmpeg;
-(BOOL)stopFFmpegInstance: (NSString *)processID;
-(BOOL)stopAllFFmpegInstances:(NSArray*) prcocesses;

@end
