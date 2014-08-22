//
//  AMAudioPrefViewController.m
//  AMAudio
//
//  Created by 王 为 on 8/22/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMAudioPrefViewController.h"
#import "AMAudioDeviceManager.h"

@interface AMAudioPrefViewController ()
@property (weak) IBOutlet NSPopUpButton *driverBox;
@property (weak) IBOutlet NSPopUpButton *inputDevBox;
@property (weak) IBOutlet NSPopUpButton *outputDevBox;
@property (weak) IBOutlet NSPopUpButton *sampleRateBox;
@property (weak) IBOutlet NSPopUpButton *bufferSizeBox;
@property (weak) IBOutlet NSButton *hogModeCheck;
@property (weak) IBOutlet NSButton *compensationCheck;
@property (weak) IBOutlet NSButton *portMornitingCheck;
@property (weak) IBOutlet NSButton *midiCheck;
@property (weak) IBOutlet NSPopUpButton *interfaceInChansBox;
@property (weak) IBOutlet NSPopUpButton *interfaceOutChansBox;

@end

@implementation AMAudioPrefViewController
{
    AMAudioDeviceManager* _devManager;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
        _devManager = [[AMAudioDeviceManager alloc] init];
        
    }
    
    return self;
}

-(void)awakeFromNib
{
     [self loadPrefs];
}

-(void)loadPrefs
{
    [self fillDriverBox];
    [self fillInputAndOutputDevice];
    [self setCheckBoxes];
}

-(void)fillDriverBox
{
    [self.driverBox removeAllItems];
    [self.driverBox addItemWithTitle:@"coreaudio"];
}

-(void)fillInputAndOutputDevice
{
    [self.inputDevBox removeAllItems];
    [self.outputDevBox removeAllItems];
    
    NSArray* inputDevices = [_devManager inputDevices];
    NSArray* outputDevices = [_devManager outputDevices];
    
    for(AMAudioDevice* dev in inputDevices){
        [self.inputDevBox addItemWithTitle:dev.devName];
    }
    
    for (AMAudioDevice* dev in outputDevices) {
        [self.outputDevBox addItemWithTitle:dev.devName];
    }
    
    [self inputDevChanged:self.inputDevBox];
    [self outputDevChanged:self.outputDevBox];
}

-(void)setCheckBoxes
{
    [self.hogModeCheck setState: NSOffState];
    [self.compensationCheck setState:NSOffState];
    [self.portMornitingCheck setState:NSOffState];
    [self.midiCheck setState:NSOffState];
}

- (IBAction)inputDevChanged:(NSPopUpButton *)sender
{
    [self deviceSelectionChanged];
}

- (IBAction)outputDevChanged:(NSPopUpButton *)sender
{
    [self deviceSelectionChanged];
}

-(void)deviceSelectionChanged
{
    NSString* inputDevName = [self.inputDevBox.selectedItem title];
    NSString* outputDevName = [self.outputDevBox.selectedItem title];
    
    AMAudioDevice* inputDev = [_devManager findDevByName:inputDevName];
    AMAudioDevice* outputDev = [_devManager findDevByName:outputDevName];
    
    if (inputDev || outputDev) {
        
        //Sample Rate
        NSArray* sampleRateSupportIn = [inputDev sampleRates];
        NSArray* sampleRateSupportOut = [outputDev sampleRates];
        NSMutableArray* commonSampleRate = [[NSMutableArray alloc] init];
        
        for(NSNumber* sIn in sampleRateSupportIn){
            for (NSNumber* sOut in sampleRateSupportOut) {
                if ([sIn isEqual:sOut]) {
                    NSString* sampleStr = [NSString stringWithFormat:@"%d", [sIn intValue]];
                    [commonSampleRate addObject:sampleStr];
                }
            }
        }
        
        [self.sampleRateBox removeAllItems];
        [self.sampleRateBox addItemsWithTitles:commonSampleRate];
        
        //Buffer Size
        NSArray* bufSizeSupportIn = [inputDev bufferSizes];
        NSArray* bufSizeSupportOut = [outputDev bufferSizes];
        NSMutableArray* commonBufSize = [[NSMutableArray alloc] init];
        
        for (NSNumber* bIn in bufSizeSupportIn) {
            for (NSNumber* bOut in bufSizeSupportOut) {
                NSString* bufSizeStr = [NSString stringWithFormat:@"%d", [bIn intValue ]];
                [commonBufSize addObject:bufSizeStr];
            }
        }
        
        [self.bufferSizeBox removeAllItems];
        [self.bufferSizeBox addItemsWithTitles:commonBufSize];
        
        //Interface input channel
        [self.interfaceInChansBox removeAllItems];
        
        int inputChansCount = [inputDev inChannels];
        for (int i = 0; i <= inputChansCount; i++) {
            NSString* chanStr = [NSString stringWithFormat:@"%d", i];
            [self.interfaceInChansBox addItemWithTitle:chanStr];
        }
        
        [self.interfaceInChansBox selectItemAtIndex:inputChansCount];
        
        //Interface output channel
        [self.interfaceOutChansBox removeAllItems];
        
        int outputChansCount = [outputDev outChanels];
        for (int i = 0; i <= outputChansCount; i++) {
            NSString* chanStr = [NSString stringWithFormat:@"%d", i];
            [self.interfaceOutChansBox addItemWithTitle:chanStr];
        }
        
        [self.interfaceOutChansBox selectItemAtIndex:outputChansCount];
    }
}



@end
