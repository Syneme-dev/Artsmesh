//
//  AMMixerViewController.h
//  AMCollectionViewTest
//
//  Created by wangwei on 26/11/14.
//  Copyright (c) 2014 wangwei. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMArtsmeshClient.h"

@interface AMMixerViewController : NSViewController

@property (weak)AMJackPort *jackport;
@property NSString* channName;
@property float volume;
@property float meter;

-(void)setMeterRange:(NSRange)range;
-(void)setVolumeRange:(NSRange)range;

@end
