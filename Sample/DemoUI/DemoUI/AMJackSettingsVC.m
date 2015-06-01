//
//  AMJackSettingsVC.m
//  Artsmesh
//
//  Created by 王为 on 11/2/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMJackSettingsVC.h"
#import "UIFramework/AMPopUpView.h"
#import "UIFramework/AMCheckBoxView.h"
#import "UIFramework/AMFoundryFontView.h"
#import "AMAudio/AMAudio.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "UIFramework/AMButtonHandler.h"

@interface AMJackSettingsVC ()<AMPopUpViewDelegeate, AMCheckBoxDelegeate>
@property (weak) IBOutlet AMPopUpView *driverBox;
@property (weak) IBOutlet AMPopUpView *inputDevBox;
@property (weak) IBOutlet AMPopUpView *outputDevBox;
@property (weak) IBOutlet AMPopUpView *sampleRateBox;
@property (weak) IBOutlet AMPopUpView *bufferSizeBox;
@property (weak) IBOutlet AMCheckBoxView *hogModeCheck;
@property (weak) IBOutlet AMCheckBoxView *compensationCheck;
@property (weak) IBOutlet AMCheckBoxView *portMornitingCheck;
@property (weak) IBOutlet AMCheckBoxView *midiCheck;
@property (weak) IBOutlet AMPopUpView *interfaceInChansBox;
@property (weak) IBOutlet AMPopUpView *interfaceOutChansBox;
@property (weak) IBOutlet NSButton *saveBtn;
@property (weak) IBOutlet NSButton *cancelBtn;
@property (weak) IBOutlet NSTextField *amVirtualChannsField;
@property (weak) IBOutlet AMFoundryFontView *virtualInputChannelsField;
@property (weak) IBOutlet AMFoundryFontView *virtualOutputChannelsField;
@property (weak) IBOutlet AMCheckBoxView *autoConnectCheck;

@end

@implementation AMJackSettingsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self.hogModeCheck setTitle:@"HOG MODE:"];
    [self.compensationCheck setTitle:@"CLOCK DRIFT COMPENSATION:"];
    [self.portMornitingCheck setTitle:@"SYSTEM PORT MORNITORING:"];
    [self.midiCheck setTitle:@"ACTIVE MIDI:"];
    [self.autoConnectCheck setTitle:@"AUTO CONNECT WITH PHYSICAL PORTS"];
    
    [self loadDriver];
    [self loadInputAndOutputDevice];
    [self loadHog];
    [self loadCompensation];
    [self loadMidi];
    [self loadMonitoring];
    [self loadVirtualChannels];
    [self loadAutoConnect];
    [self saveConfig:nil];
    
    [self loadAutoConnect];
    [self setButtons];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(textDidChange:)
     name:NSControlTextDidChangeNotification
     object:nil];

}


-(void)viewWillDisappear
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)loadDriver
{
    [self.driverBox removeAllItems];
    [self.driverBox addItemWithTitle:@"coreaudio"];
    [self.driverBox selectItemAtIndex:0];
}


-(void)loadInputAndOutputDevice
{
    [self.inputDevBox removeAllItems];
    [self.outputDevBox removeAllItems];
    
    NSArray* inputDevices = [[[AMAudio sharedInstance] audioDeviceManager] inputDevices];
    NSArray* outputDevices = [[[AMAudio sharedInstance] audioDeviceManager] outputDevices];
    
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


- (void)inputDevChanged:(AMPopUpView *)sender
{
    NSString* inputDevName = self.inputDevBox.stringValue;
    AMAudioDevice* inputDev = [[[AMAudio sharedInstance] audioDeviceManager] findDevByName:inputDevName];
    
    NSString* outputDevName = self.outputDevBox.stringValue;
    AMAudioDevice* outputDev = [[[AMAudio sharedInstance] audioDeviceManager] findDevByName:outputDevName];
    
    if ([inputDev isAggregateDevice]) {
        [self.outputDevBox selectItemWithTitle:inputDevName];
    }else if([outputDev isAggregateDevice]){
        NSArray* outDevs = [[[AMAudio sharedInstance] audioDeviceManager] outputDevices];
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
    AMAudioDevice* inputDev = [[[AMAudio sharedInstance] audioDeviceManager] findDevByName:inputDevName];
    
    NSString* outputDevName = self.outputDevBox.stringValue;
    AMAudioDevice* outputDev = [[[AMAudio sharedInstance] audioDeviceManager] findDevByName:outputDevName];
    
    if ([outputDev isAggregateDevice]) {
        [self.inputDevBox selectItemWithTitle:outputDevName];
    }else if([inputDev isAggregateDevice]){
        NSArray* inDevs = [[[AMAudio sharedInstance] audioDeviceManager] inputDevices];
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
    
    AMAudioDevice* inputDev = [[[AMAudio sharedInstance] audioDeviceManager] findDevByName:inputDevName];
    AMAudioDevice* outputDev = [[[AMAudio sharedInstance] audioDeviceManager] findDevByName:outputDevName];
    
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


-(void)loadHog
{
    self.hogModeCheck.checked = [[NSUserDefaults standardUserDefaults] boolForKey:Preference_Jack_HogMode];
}


-(void)loadCompensation
{
    self.compensationCheck.checked = [[NSUserDefaults standardUserDefaults] boolForKey:Preference_Jack_ClockDriftComp];
}


-(void)loadMonitoring
{
    self.portMornitingCheck.checked = [[NSUserDefaults standardUserDefaults] boolForKey:Preference_Jack_PortMoniting];
}


-(void)loadMidi
{
    self.midiCheck.checked = [[NSUserDefaults standardUserDefaults] boolForKey:Preference_Jack_ActiveMIDI];
}

-(void)loadAutoConnect
{
    self.autoConnectCheck.checked = [[NSUserDefaults standardUserDefaults] boolForKey:Preference_Jack_AutoConnect];
}


-(void)loadVirtualChannels
{
    self.amVirtualChannsField.stringValue = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jack_RouterVirtualChanns];
    
    self.virtualInputChannelsField.stringValue = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jack_VirtualInChannels];
    
     self.virtualOutputChannelsField.stringValue = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_Jack_VirtualOutChannels];
}


-(void)setButtons
{
    [self.saveBtn setEnabled:NO];
    [self.cancelBtn setEnabled:NO];
    
    [AMButtonHandler changeTabTextColor:self.saveBtn toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.cancelBtn toColor:UI_Color_blue];
}


- (IBAction)saveConfig:(NSButton *)sender
{
    int virtualNum = [self.amVirtualChannsField.stringValue intValue];
    if(virtualNum <= 0 || virtualNum >8){
        self.amVirtualChannsField.stringValue = @"2";
        return;
    }

    [self.saveBtn setEnabled:NO];
    [self.cancelBtn setEnabled:NO];
    
    //save preferecces
    [[AMPreferenceManager standardUserDefaults]
     setObject:self.driverBox.stringValue forKey:Preference_Jack_Driver];
    
    [[AMPreferenceManager standardUserDefaults]
     setObject:self.inputDevBox.stringValue forKey:Preference_Jack_InputDevice];
    
    [[AMPreferenceManager standardUserDefaults]
     setObject:self.outputDevBox.stringValue forKey:Preference_Jack_OutputDevice];
    
    [[AMPreferenceManager standardUserDefaults]
     setObject:self.sampleRateBox.stringValue forKey:Preference_Jack_SampleRate];
    
    [[AMPreferenceManager standardUserDefaults]
     setObject:self.bufferSizeBox.stringValue forKey:Preference_Jack_BufferSize];
    
    [[AMPreferenceManager standardUserDefaults]
     setObject:self.interfaceInChansBox.stringValue forKey:Preference_Jack_InterfaceInChans];
    
    [[AMPreferenceManager standardUserDefaults]
     setObject:self.interfaceOutChansBox.stringValue forKey:Preference_Jack_InterfaceOutChanns];
    
    [[AMPreferenceManager standardUserDefaults]
     setObject:self.amVirtualChannsField.stringValue forKey:Preference_Jack_RouterVirtualChanns];
    
    [[AMPreferenceManager standardUserDefaults]
     setObject:self.virtualInputChannelsField.stringValue forKey:Preference_Jack_VirtualInChannels];
    
    [[AMPreferenceManager standardUserDefaults]
     setObject:self.virtualOutputChannelsField.stringValue forKey:Preference_Jack_VirtualOutChannels];
    
    [[AMPreferenceManager standardUserDefaults]
     setBool:self.hogModeCheck.checked forKey:Preference_Jack_HogMode];
    
    [[AMPreferenceManager standardUserDefaults]
     setBool:self.compensationCheck.checked forKey:Preference_Jack_ClockDriftComp];
    
    [[AMPreferenceManager standardUserDefaults]
     setBool:self.portMornitingCheck.checked forKey:Preference_Jack_PortMoniting];
    
    [[AMPreferenceManager standardUserDefaults]
     setBool:self.midiCheck.checked forKey:Preference_Jack_ActiveMIDI];
    
    [[AMPreferenceManager standardUserDefaults]
     setBool:self.autoConnectCheck.checked forKey:Preference_Jack_AutoConnect];
}


- (IBAction)restoreConfig:(NSButton *)sender
{
    [self.driverBox selectItemAtIndex:0];

    [self.inputDevBox selectItemWithTitle:[[AMPreferenceManager standardUserDefaults]
                                           stringForKey:Preference_Jack_InputDevice]];
    
    [self.outputDevBox selectItemWithTitle:[[AMPreferenceManager standardUserDefaults]
                                            stringForKey:Preference_Jack_OutputDevice]];
    
    [self.sampleRateBox selectItemWithTitle:[[AMPreferenceManager standardUserDefaults]
                                             stringForKey:Preference_Jack_SampleRate]];
    
    [self.bufferSizeBox selectItemWithTitle:[[AMPreferenceManager standardUserDefaults]
                                             stringForKey:Preference_Jack_BufferSize]];
    
    [self.interfaceInChansBox selectItemWithTitle:[[AMPreferenceManager standardUserDefaults]
                                                   stringForKey:Preference_Jack_InterfaceInChans]];
    
    [self.interfaceOutChansBox selectItemWithTitle:[[AMPreferenceManager standardUserDefaults]
                                                    stringForKey:Preference_Jack_InterfaceOutChanns]];
    
    self.amVirtualChannsField.stringValue = [[AMPreferenceManager standardUserDefaults]
                                             stringForKey:Preference_Jack_RouterVirtualChanns];
   
    self.virtualInputChannelsField.stringValue =[[AMPreferenceManager standardUserDefaults]
                                stringForKey:Preference_Jack_VirtualInChannels];
    
    self.virtualOutputChannelsField.stringValue=[[AMPreferenceManager standardUserDefaults]
                                stringForKey:Preference_Jack_VirtualOutChannels];
    
    [self.hogModeCheck setChecked:[[AMPreferenceManager standardUserDefaults]
                                   boolForKey:Preference_Jack_HogMode]];
    
    [self.compensationCheck setChecked:[[AMPreferenceManager standardUserDefaults]
                                        boolForKey:Preference_Jack_ClockDriftComp]];
    
    [self.portMornitingCheck setChecked:[[AMPreferenceManager standardUserDefaults]
                                         boolForKey:Preference_Jack_PortMoniting]];
    
    [self.midiCheck setChecked:[[AMPreferenceManager standardUserDefaults]
                                boolForKey:Preference_Jack_ActiveMIDI]];
    
    
    [self.autoConnectCheck setChecked:[[AMPreferenceManager standardUserDefaults]
                                boolForKey:Preference_Jack_AutoConnect]];

    
    [self.saveBtn setEnabled:NO];
    [self.cancelBtn setEnabled:NO];
}



#pragma mark AMPopUpViewDelegeate
-(void)itemSelected:(AMPopUpView*)sender
{
    [self enableButtons];
    
    if ([sender isEqual:self.inputDevBox]) {
        [self inputDevChanged:sender];
        return;
    }
    
    if([sender isEqual:self.outputDevBox]){
        [self outputDevChanged:sender];
        return;
    }
}


- (void)enableButtons
{
    [self.saveBtn setEnabled:YES];
    [self.cancelBtn setEnabled:YES];
}


#pragma mark AMCheckBoxDelegeate
-(void)onChecked:(AMCheckBoxView*)sender
{
    [self enableButtons];
}

#pragma mark TextField Edited
- (void)textDidChange:(NSNotification *)aNotification
{
    NSTextField *sender=[aNotification object];
    if ([sender isEqualTo:self.amVirtualChannsField]) {
        [self.saveBtn setEnabled:YES];
        [self.cancelBtn setEnabled:YES];
    }
}


@end
