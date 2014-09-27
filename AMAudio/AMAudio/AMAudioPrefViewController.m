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
#import "UIFrameWork/AMPopUpView.h"
#import "UIFrameWork/AMCheckBoxView.h"
#import "AMPreferenceManager/AMPreferenceManager.h"

@interface AMAudioPrefViewController ()<AMPopUpViewDelegeate, AMCheckBoxDelegeate>
@property (weak) IBOutlet AMPopUpView *driverBox;
@property (weak) IBOutlet AMPopUpView *inputDevBox;
@property (weak) IBOutlet AMPopUpView *outputDevBox;
@property (weak) IBOutlet AMPopUpView *sampleRateBox;
@property (weak) IBOutlet AMPopUpView *bufferSizeBox;
@property (weak) IBOutlet AMCheckBoxView *hogModeCheck;
@property (weak) IBOutlet AMCheckBoxView *compensationCheck;
@property (weak) IBOutlet AMCheckBoxView *portMornitingCheck;
@property (weak) IBOutlet AMCheckBoxView *midiCheck;


//@property (weak) IBOutlet NSButton *hogModeCheck;
//@property (weak) IBOutlet NSButton *compensationCheck;
//@property (weak) IBOutlet NSButton *portMornitingCheck;
//@property (weak) IBOutlet NSButton *midiCheck;
@property (weak) IBOutlet AMPopUpView *interfaceInChansBox;
@property (weak) IBOutlet AMPopUpView *interfaceOutChansBox;
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
    self.inputDevBox.delegate = self;
    self.outputDevBox.delegate = self;
    self.driverBox.delegate = self;
    self.sampleRateBox.delegate = self;
    self.bufferSizeBox.delegate = self;
    self.hogModeCheck.delegate = self;
    self.compensationCheck.delegate = self;
    self.midiCheck.delegate = self;
    self.portMornitingCheck.delegate = self;
    
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
    [self.driverBox selectItemAtIndex:0];
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
    
    NSString* prefInDevName = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jack_InputDevice];
    NSString* prefOutDevName = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jack_OutputDevice];
    
    [self.inputDevBox selectItemWithTitle:prefInDevName];
    [self.outputDevBox selectItemWithTitle:prefOutDevName];

    [self inputDevChanged:nil];
    [self outputDevChanged:nil];
}

-(void)setCheckBoxes
{
    BOOL hogMode = [[AMPreferenceManager standardUserDefaults] boolForKey:Preference_Jack_HogMode];
    BOOL portMoniting = [[AMPreferenceManager standardUserDefaults] boolForKey:Preference_Jack_PortMoniting];
    BOOL compensation = [[AMPreferenceManager standardUserDefaults] boolForKey:Preference_Jack_ClockDriftComp];
    BOOL midi = [[AMPreferenceManager standardUserDefaults] boolForKey:Preference_Jack_ActiveMIDI];
    
    [self.hogModeCheck setTitle:@"Hog Mode:"];
    [self.hogModeCheck setChecked:hogMode];
    
    [self.compensationCheck setTitle:@"Clock Drift Compensation:"];
    [self.compensationCheck setChecked:compensation];
    
    [self.portMornitingCheck setTitle:@"System Port Monitoring:"];
    [self.portMornitingCheck setChecked:portMoniting];
    
    [self.midiCheck setTitle:@"Active MIDI:"];
    [self.midiCheck setChecked:midi];
}

-(void)itemSelected:(AMPopUpView*)sender{
    if ([sender isEqual:self.inputDevBox]) {
        [self inputDevChanged:sender];
    }else if([sender isEqual:self.outputDevBox]){
        [self outputDevChanged:sender];
    }else if([sender isEqual:self.sampleRateBox]){
        [self comboChanged:sender];
    }else if([sender isEqual:self.bufferSizeBox]){
        [self comboChanged:sender];
    }
}

-(void)onChecked:(AMCheckBoxView*)sender
{
    [self.saveBtn setEnabled:YES];
    [self.cancelBtn setEnabled:YES];
}

- (void)inputDevChanged:(AMPopUpView *)sender
{
    NSString* inputDevName = self.inputDevBox.stringValue;
    AMAudioDevice* inputDev = [_devManager findDevByName:inputDevName];
    
    NSString* outputDevName = self.outputDevBox.stringValue;
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

- (void)outputDevChanged:(AMPopUpView *)sender
{
    NSString* inputDevName = self.inputDevBox.stringValue;
    AMAudioDevice* inputDev = [_devManager findDevByName:inputDevName];
    
    NSString* outputDevName = self.outputDevBox.stringValue;
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
    NSString* inputDevName = self.inputDevBox.stringValue;
    NSString* outputDevName = self.outputDevBox.stringValue;
    
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
        
        NSString* prefSampleRate = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jack_SampleRate];
        [self.sampleRateBox selectItemWithTitle:prefSampleRate];
        
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
        
        NSString* prefBufSize = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jack_BufferSize];
        [self.bufferSizeBox selectItemWithTitle:prefBufSize];
        
        //Interface input channel
        [self.interfaceInChansBox removeAllItems];
        
        int inputChansCount = [inputDev inChannels];
        for (int i = 0; i <= inputChansCount; i++) {
            NSString* chanStr = [NSString stringWithFormat:@"%d", i];
            [self.interfaceInChansBox addItemWithTitle:chanStr];
        }
        
        NSString* prefInput = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jack_InterfaceInChans];
        [self.interfaceInChansBox selectItemWithTitle:prefInput];
    
        
        //Interface output channel
        [self.interfaceOutChansBox removeAllItems];
        
        int outputChansCount = [outputDev outChanels];
        for (int i = 0; i <= outputChansCount; i++) {
            NSString* chanStr = [NSString stringWithFormat:@"%d", i];
            [self.interfaceOutChansBox addItemWithTitle:chanStr];
        }
        
        NSString* prefOutput = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jack_InterfaceOutChanns];
        [self.interfaceOutChansBox selectItemWithTitle:prefOutput];
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
    
    self.jackManager.jackCfg.driver = self.driverBox.stringValue;
    
    NSString* inputDevName = self.inputDevBox.stringValue;
    AMAudioDevice* inputDev = [_devManager findDevByName:inputDevName];
    if(inputDev){
        self.jackManager.jackCfg.inputDevUID = inputDev.devUID;
    }
    
    NSString* outputDevName = self.outputDevBox.stringValue;
    AMAudioDevice* outputDev = [_devManager findDevByName:outputDevName];
    if (outputDev) {
        self.jackManager.jackCfg.outputDevUID = outputDev.devUID;
    }
    
    self.jackManager.jackCfg.sampleRate = [self.sampleRateBox.stringValue intValue];
    self.jackManager.jackCfg.bufferSize = [self.bufferSizeBox.stringValue intValue];
    self.jackManager.jackCfg.inChansCount = [self.interfaceInChansBox.stringValue intValue];
    self.jackManager.jackCfg.outChansCount = [self.interfaceOutChansBox.stringValue intValue];
    self.jackManager.jackCfg.hogMode = [self.hogModeCheck checked];
    self.jackManager.jackCfg.clockDriftCompensation = [self.compensationCheck checked];
    self.jackManager.jackCfg.systemPortMonitoring = [self.portMornitingCheck checked];
    self.jackManager.jackCfg.activeMIDI = [self.midiCheck checked];
    [self.jackManager.jackCfg archiveConfigs];
    
    [self.saveBtn setEnabled:NO];
    [self.cancelBtn setEnabled:NO];
    
    //save preferecces
    [[AMPreferenceManager standardUserDefaults] setObject:self.jackManager.jackCfg.driver forKey:Preference_Jack_Driver];
    [[AMPreferenceManager standardUserDefaults] setObject:inputDevName forKey:Preference_Jack_InputDevice];
    [[AMPreferenceManager standardUserDefaults] setObject:outputDevName forKey:Preference_Jack_OutputDevice];
    [[AMPreferenceManager standardUserDefaults] setObject:self.sampleRateBox.stringValue forKey:Preference_Jack_SampleRate];
    [[AMPreferenceManager standardUserDefaults] setObject:self.bufferSizeBox.stringValue forKey:Preference_Jack_BufferSize];
    [[AMPreferenceManager standardUserDefaults] setObject:self.interfaceInChansBox.stringValue forKey:Preference_Jack_InterfaceInChans];
    [[AMPreferenceManager standardUserDefaults] setObject:self.interfaceOutChansBox.stringValue forKey:Preference_Jack_InterfaceOutChanns];
    
    if (self.jackManager.jackCfg.hogMode) {
        [[AMPreferenceManager standardUserDefaults] setObject:@"YES" forKey:Preference_Jack_HogMode];
    }else{
        [[AMPreferenceManager standardUserDefaults] setObject:@"NO" forKey:Preference_Jack_HogMode];
    }
    
    if (self.jackManager.jackCfg.clockDriftCompensation) {
        [[AMPreferenceManager standardUserDefaults] setObject:@"YES" forKey:Preference_Jack_ClockDriftComp];
    }else{
        [[AMPreferenceManager standardUserDefaults] setObject:@"NO" forKey:Preference_Jack_ClockDriftComp];
    }
    
    if (self.jackManager.jackCfg.systemPortMonitoring) {
        [[AMPreferenceManager standardUserDefaults] setObject:@"YES" forKey:Preference_Jack_PortMoniting];
    }else{
        [[AMPreferenceManager standardUserDefaults] setObject:@"NO" forKey:Preference_Jack_PortMoniting];
    }
    
    if (self.jackManager.jackCfg.activeMIDI) {
        [[AMPreferenceManager standardUserDefaults] setObject:@"YES" forKey:Preference_Jack_ActiveMIDI];
    }else{
        [[AMPreferenceManager standardUserDefaults] setObject:@"NO" forKey:Preference_Jack_ActiveMIDI];
    }

}

- (IBAction)restoreConfig:(NSButton *)sender
{
    [self.driverBox selectItemAtIndex:0];
    
    NSString* inputDev = [[AMPreferenceManager standardUserDefaults]
                          stringForKey:Preference_Jack_InputDevice];
    [self.inputDevBox selectItemWithTitle:inputDev];
    
    NSString* outputDev = [[AMPreferenceManager standardUserDefaults]
                           stringForKey:Preference_Jack_OutputDevice];
    [self.outputDevBox selectItemWithTitle:outputDev];
    
    NSString* sampleRate = [[AMPreferenceManager standardUserDefaults]
                            stringForKey:Preference_Jack_SampleRate];
    [self.sampleRateBox selectItemWithTitle:sampleRate];
    
    NSString* bufferSize = [[AMPreferenceManager standardUserDefaults]
                            stringForKey:Preference_Jack_BufferSize];
    [self.bufferSizeBox selectItemWithTitle:bufferSize];
    
    NSString* inChanns = [[AMPreferenceManager standardUserDefaults]
                            stringForKey:Preference_Jack_InterfaceInChans];
    [self.interfaceInChansBox selectItemWithTitle:inChanns];
    
    NSString* outChanns = [[AMPreferenceManager standardUserDefaults]
                          stringForKey:Preference_Jack_InterfaceOutChanns];
    [self.interfaceOutChansBox selectItemWithTitle:outChanns];
    
    BOOL hogMode = [[AMPreferenceManager standardUserDefaults]
                           boolForKey:Preference_Jack_HogMode];
    [self.hogModeCheck setChecked:hogMode];
    
    BOOL compensation = [[AMPreferenceManager standardUserDefaults]
                    boolForKey:Preference_Jack_ClockDriftComp];
    [self.compensationCheck setChecked:compensation];
    
    BOOL portMorniting = [[AMPreferenceManager standardUserDefaults]
                         boolForKey:Preference_Jack_PortMoniting];
    [self.portMornitingCheck setChecked:portMorniting];
    
    BOOL midi = [[AMPreferenceManager standardUserDefaults]
                          boolForKey:Preference_Jack_ActiveMIDI];
    [self.midiCheck setChecked:midi];
    
    [self.saveBtn setEnabled:NO];
    [self.cancelBtn setEnabled:NO];
}

- (void)comboChanged:(AMPopUpView *)sender
{
    [self.saveBtn setEnabled:YES];
    [self.cancelBtn setEnabled:YES];
}

@end
