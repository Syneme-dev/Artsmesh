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
#import "AMAudioMuteButton.h"

@interface AMMixerViewController ()<AMAudioSliderDelegate>
@property (weak) IBOutlet AMAudioSlider *volSlider;
@property (weak) IBOutlet AMAudioMeter *meterView;
@property (weak) IBOutlet NSTextField *channNameField;

@end

@implementation AMMixerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    self.volSlider.delegate = self;
}

-(void)slider:(AMAudioSlider *)slider ValueChanged:(float)value
{
    self.volume = value;
    self.jackport.volume = value;
}

-(void)setChannName:(NSString *)channName
{
    channName = [channName uppercaseStringWithLocale:[NSLocale currentLocale]];
    self.channNameField.stringValue = channName;
}

-(NSString *)channName{
    return self.channNameField.stringValue;
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

- (IBAction)mute:(id)sender
{
    AMAudioMuteButton *btn = (AMAudioMuteButton *)sender;
    if ([btn.title isEqualToString:@"Mute"]) {
        btn.title = @"Unmute";
        [(AMAudioMuteButton *)sender setButtonOnState:YES];
        self.jackport.volume = 0.0;
    }else{
        btn.title = @"Mute";
        [(AMAudioMuteButton *)sender setButtonOnState:NO];
        self.jackport.volume = self.volume;
    }
}


@end
