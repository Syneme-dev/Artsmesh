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
    if (self.jackManager == nil) {
        NSException* exp = [[NSException alloc]
                            initWithName:@"Code Bug!"
                            reason:@"to save config, must set manager first"
                            userInfo:nil];
        [exp raise];
    }
    
    self.jackManager.jackCfg.driver = self.driverBox.title;
    
    NSString* inputDevName = self.inputDevBox.title;
    AMAudioDevice* inputDev = [_devManager findDevByName:inputDevName];
    if(inputDev){
        self.jackManager.jackCfg.inputDevUID = inputDev.devUID;
    }
    
    NSString* outputDevName = self.outputDevBox.title;
    AMAudioDevice* outputDev = [_devManager findDevByName:outputDevName];
    if (outputDev) {
        self.jackManager.jackCfg.outputDevUID = outputDev.devUID;
    }
    
    self.jackManager.jackCfg.sampleRate = [self.sampleRateBox.title intValue];
    self.jackManager.jackCfg.bufferSize = [self.bufferSizeBox.title intValue];
    
    self.jackManager.jackCfg.inChansCount = [self.interfaceInChansBox.title intValue];
    self.jackManager.jackCfg.outChansCount = [self.interfaceOutChansBox.title intValue];
    
    self.jackManager.jackCfg.hogMode = [self.hogModeCheck state] == 1;
    self.jackManager.jackCfg.clockDriftCompensation = [self.compensationCheck state] == 1;
    self.jackManager.jackCfg.systemPortMonitoring = [self.portMornitingCheck state] == 1;
    self.jackManager.jackCfg.activeMIDI = [self.midiCheck state] == 1;
    
    [self.jackManager.jackCfg archiveConfigs];
    
    [self.saveBtn setEnabled:NO];
    [self.cancelBtn setEnabled:NO];

}


- (IBAction)restoreConfig:(NSButton *)sender
{
    [self.driverBox selectItemAtIndex:0];
    
    AMAudioDevice* inputDev = [_devManager findDevByUID:self.jackManager.jackCfg.inputDevUID];
    [self.inputDevBox selectItemWithTitle:inputDev.devName];
    
    AMAudioDevice* outputDev = [_devManager findDevByUID:self.jackManager.jackCfg.outputDevUID];
    [self.outputDevBox selectItemWithTitle:outputDev.devName];
    
    NSString* sampleRateStr = [[NSString alloc ] initWithFormat:@"%d", self.jackManager.jackCfg.sampleRate];
    [self.sampleRateBox selectItemWithTitle:sampleRateStr];
    
    NSString* bufferSizeStr = [[NSString alloc ] initWithFormat:@"%d", self.jackManager.jackCfg.bufferSize];
    [self.bufferSizeBox selectItemWithTitle:bufferSizeStr];
    
    NSString* inChansStr = [[NSString alloc ] initWithFormat:@"%d", self.jackManager.jackCfg.interfaceInputChannel];
    [self.interfaceInChansBox selectItemWithTitle:inChansStr];
    
    NSString* outChansStr = [[NSString alloc ] initWithFormat:@"%d", self.jackManager.jackCfg.interfaceOutputChannel];
    [self.interfaceOutChansBox selectItemWithTitle:outChansStr];
    
    [self.hogModeCheck setState:(self.jackManager.jackCfg.hogMode)?1:0];
    [self.compensationCheck setState:(self.jackManager.jackCfg.clockDriftCompensation)?1:0];
    [self.portMornitingCheck setState:(self.jackManager.jackCfg.systemPortMonitoring)?1:0];
    [self.midiCheck setState:(self.jackManager.jackCfg.activeMIDI)?1:0];
    
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
