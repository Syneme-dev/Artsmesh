//
//  AMVolumeBar.h
//  AMAudio
//
//  Created by 王为 on 10/11/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol AMVolumeBarDelegate;

@interface AMVolumeBar : NSObject

@property NSString* name;
@property float volume;
@property float meter;
@property BOOL isMute;

@property (weak) id<AMVolumeBarDelegate> delegate;

@end


@protocol AMVolumeBarDelegate <NSObject>

-(void)volumeBarChanged:(AMVolumeBar*)bar;

@end
