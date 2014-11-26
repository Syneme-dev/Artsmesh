//
//  AMMixerViewController.m
//  AMCollectionViewTest
//
//  Created by wangwei on 26/11/14.
//  Copyright (c) 2014 wangwei. All rights reserved.
//

#import "AMMixerViewController.h"
#import "AMAudioMeter.h"
#import "AMAudioSlider.h"

@interface AMMixerViewController ()<AMAudioSliderDelegate>
@property (weak) IBOutlet AMAudioSlider *volSlider;
@property (weak) IBOutlet AMAudioMeter *meterView;
@property (weak) IBOutlet NSTextField *channNameField;

@end

@implementation AMMixerViewController
{
    float _volume;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    self.volSlider.delegate = self;
}

-(void)slider:(AMAudioSlider *)slider ValueChanged:(float)value
{
    self.volume = value;
}

-(void)setChannName:(NSString *)channName
{
    self.channNameField.stringValue = channName;
}

-(NSString *)channName{
    return self.channNameField.stringValue;
}

-(void)setVolume:(float)volume
{
    [self willChangeValueForKey:@"volume"];
    _volume = volume;
    [self didChangeValueForKey:@"volume"];
}

-(float)volume
{
    return _volume;
}

-(void)setMeter:(float)meter
{
    self.meterView.value = meter;
}

-(float)meter
{
    return self.meterView.value;
}

-(void)setMeterRange:(NSRange)range
{
    self.meterView.valueRange = range;
}

-(void)setVolumeRange:(NSRange)range
{
    self.volSlider.valueRange = range;
}



@end
