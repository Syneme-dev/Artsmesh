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

-(BOOL)sendP2P:(AMFFmpegConfigs *)cfgs;
-(BOOL)stopFFmpeg;

@end
