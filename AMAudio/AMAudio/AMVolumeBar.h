//
//  AMVolumeBar.h
//  AMAudio
//
//  Created by 王为 on 10/11/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMVolumeBar : NSObject

@property NSString* name;
@property float volume;
@property float meter;
@property BOOL isMute;

@end
