//
//  AMAudioPrefViewController.m
//  AMAudio
//
//  Created by 王 为 on 8/22/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMAudioPrefViewController.h"
#import "AMAudioDeviceManager.h"
#import "AMJackConfigs.h"

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
@property (weak) IBOutlet NSButton *saveBtn;
@property (weak) IBOutlet NSButton *cancelBtn;


@end

@implementation AMAudioPrefViewController
{
    AMAudioDeviceManager* _devManager;
    BOOL _isEdited;
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
    [self.saveBtn setEnabled:NO];
    [self.cancelBtn setEnabled:NO];
    
}

-(void)loadPrefs
{
    [self fillDriverBox];
    [self fillInputAndOutputDevice];
    [self setCheckBoxes];
    [self saveConfig:nil];
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
    
    [self inputDevChanged:nil];
    [self outputDevChanged:nil];
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
    NSString* inputDevName = [self.inputDevBox.selectedItem title];
    AMAudioDevice* inputDev = [_devManager findDevByName:inputDevName];
    
    NSString* outputDevName = [self.outputDevBox.selectedItem title];
    AMAudioDevice* outputDev = [_devManager findDevByName:outputDevName];
    
    if ([inputDev isAggregateDevice]) {
        [self.outputDevBox selectItemWithTitle:inputDevName];
    }else if([outputDev isAggregateDevice]){
        NSArray* outDevs = [_devManager outputDevices];
        for (AMAudioDevice* dev in outDevs) {
            if(![dev isAggregateDevice]){
                [self.outputDevBox selectItemWithTitle:dev.devName];
            }
        }
    }
    
    [self deviceSelectionChanged];
    
    if (sender != nil){
        [self.saveBtn setEnabled:YES];
        [self.cancelBtn setEnabled:YES];
    }
}

- (IBAction)outputDevChanged:(NSPopUpButton *)sender
{
    NSString* inputDevName = [self.inputDevBox.selectedItem title];
    AMAudioDevice* inputDev = [_devManager findDevByName:inputDevName];
    
    NSString* outputDevName = [self.outputDevBox.selectedItem title];
    AMAudioDevice* outputDev = [_devManager findDevByName:outputDevName];
    
    if ([outputDev isAggregateDevice]) {
        [self.inputDevBox selectItemWithTitle:outputDevName];
    }else if([inputDev isAggregateDevice]){
        NSArray* inDevs = [_devManager inputDevices];
        for (AMAudioDevice* dev in inDevs) {
            if(![dev isAggregateDevice]){
                [self.inputDevBox selectItemWithTitle:dev.devName];
            }
        }
    }
    
    [self deviceSelectionChanged];
    
    if (sender != nil){
        [self.saveBtn setEnabled:YES];
        [self.cancelBtn setEnabled:YES];
    }
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
                if ([bIn isEqual:bOut]){
                    NSString* bufSizeStr = [NSString stringWithFormat:@"%d", [bIn intValue ]];
                    [commonBufSize addObject:bufSizeStr];
                }
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

- (IBAction)saveConfig:(NSButton *)sender
{
    if (self.jackConfig) {
        self.jackConfig.driver = self.driverBox.stringValue;
        
        NSString* inputDevName = self.inputDevBox.title;
        AMAudioDevice* inputDev = [_devManager findDevByName:inputDevName];
        if(inputDev){
            self.jackConfig.inputDevUID = inputDev.devUID;
        }
        
        NSString* outputDevName = self.outputDevBox.title;
        AMAudioDevice* outputDev = [_devManager findDevByName:outputDevName];
        if (outputDev) {
            self.jackConfig.outputDevUID = outputDev.devUID;
        }
        
        self.jackConfig.sampleRate = [self.sampleRateBox.title intValue];
        self.jackConfig.bufferSize = [self.bufferSizeBox.title intValue];
        
        self.jackConfig.inChansCount = [self.interfaceInChansBox.title intValue];
        self.jackConfig.outChansCount = [self.interfaceOutChansBox.title intValue];
        
        self.jackConfig.hogMode = [self.hogModeCheck state] == 1;
        self.jackConfig.clockDriftCompensation = [self.compensationCheck state] == 1;
        self.jackConfig.systemPortMonitoring = [self.portMornitingCheck state] == 1;
        self.jackConfig.activeMIDI = [self.midiCheck state] == 1;
        
        [self.jackConfig archiveConfigs];
    }
    
    [self.saveBtn setEnabled:NO];
    [self.cancelBtn setEnabled:NO];

}


- (IBAction)restoreConfig:(NSButton *)sender
{
    [self.driverBox selectItemAtIndex:0];
    
    AMAudioDevice* inputDev = [_devManager findDevByUID:self.jackConfig.inputDevUID];
    [self.inputDevBox selectItemWithTitle:inputDev.devName];
    
    AMAudioDevice* outputDev = [_devManager findDevByUID:self.jackConfig.outputDevUID];
    [self.outputDevBox selectItemWithTitle:outputDev.devName];
    
    NSString* sampleRateStr = [[NSString alloc ] initWithFormat:@"%d", self.jackConfig.sampleRate];
    [self.sampleRateBox selectItemWithTitle:sampleRateStr];
    
    NSString* bufferSizeStr = [[NSString alloc ] initWithFormat:@"%d", self.jackConfig.bufferSize];
    [self.bufferSizeBox selectItemWithTitle:bufferSizeStr];
    
    NSString* inChansStr = [[NSString alloc ] initWithFormat:@"%d", self.jackConfig.interfaceInputChannel];
    [self.interfaceInChansBox selectItemWithTitle:inChansStr];
    
    NSString* outChansStr = [[NSString alloc ] initWithFormat:@"%d", self.jackConfig.interfaceOutputChannel];
    [self.interfaceOutChansBox selectItemWithTitle:outChansStr];
    
    [self.hogModeCheck setState:(self.jackConfig.hogMode)?1:0];
    [self.compensationCheck setState:(self.jackConfig.clockDriftCompensation)?1:0];
    [self.portMornitingCheck setState:(self.jackConfig.systemPortMonitoring)?1:0];
    [self.midiCheck setState:(self.jackConfig.activeMIDI)?1:0];
    
    [self.saveBtn setEnabled:NO];
    [self.cancelBtn setEnabled:NO];
}

- (IBAction)comboChanged:(NSPopUpButton *)sender
{
    [self.saveBtn setEnabled:YES];
    [self.cancelBtn setEnabled:YES];
}

- (IBAction)checkboxChanged:(NSButton *)sender
{
    [self.saveBtn setEnabled:YES];
    [self.cancelBtn setEnabled:YES];
}

@end
