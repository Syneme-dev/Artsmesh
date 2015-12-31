//
//  AMIPerfConfig.m
//  Artsmesh
//
//  Created by whiskyzed on 7/3/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMIPerfConfigWC.h"
#import "UIFramework/AMFoundryFontView.h"
#import "UIFramework/AMCheckBoxView.h"
#import "UIFramework/AMRatioButtonView.h"
#import "UIFramework/AMPopUpView.h"
#import "UIFramework/AMButtonHandler.h"
#import "UIFramework/AMBlueBorderButton.h"
#import "AMPreferenceManager/AMPreferenceManager.h"

NSString* const AMIPerfServerStartNotification = @"IPerfStartServerNotification";

@interface AMIPerfConfigWC ()<AMPopUpViewDelegeate>
//@property (nonatomic)  NSInteger    tcpBufferLen;
//@property (nonatomic)  NSInteger    udpBufferLen;
@property (weak) IBOutlet AMBlueBorderButton *cancelButton;
@property (weak) IBOutlet AMBlueBorderButton *saveButton;
@property (weak) IBOutlet NSTextField *bufferLenTF;
@property (weak) IBOutlet AMPopUpView *roleSelector;
@property (weak) IBOutlet AMCheckBoxView* useUDPCheck;
@property (weak) IBOutlet NSTextField *portTF;
@property (weak) IBOutlet NSTextField *bandwithTF;
@property (weak) IBOutlet AMCheckBoxView *tradeoffCheck;
@property (weak) IBOutlet AMCheckBoxView *dualtestCheck;
@end

@implementation AMIPerfConfig

@end

@implementation AMIPerfConfigWC

- (void) saveDefaultPreference
{

    
    [[AMPreferenceManager standardUserDefaults] setObject:_roleSelector.stringValue
                                                   forKey:Preference_iPerf_Role];

    [[AMPreferenceManager standardUserDefaults] setObject:[self checkBoolString:_useUDPCheck]
                                                   forKey:Preference_iPerf_UseUDP];
    
    [[AMPreferenceManager standardUserDefaults] setObject:_portTF.stringValue
                                                   forKey:Preference_iPerf_Port];
    
    [[AMPreferenceManager standardUserDefaults] setObject:_bandwithTF.stringValue
                                                   forKey:Preference_iPerf_Bandwith];
    
    [[AMPreferenceManager standardUserDefaults] setObject:_bufferLenTF.stringValue
                                                   forKey:Preference_iPerf_BufferLen];
    
    [[AMPreferenceManager standardUserDefaults] setObject:[self checkBoolString:_tradeoffCheck]
                                                   forKey:Preference_iPerf_Tradeoff];
    
    [[AMPreferenceManager standardUserDefaults] setObject:[self checkBoolString:_dualtestCheck]
                                                   forKey:Preference_iPerf_Dualtest];
}

- (NSString*) checkBoolString : (AMCheckBoxView*) check
{
    return check.checked ? @"YES" : @"NO";
}

- (void) loadDefaultPreference
{
    NSString *roleStr = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_iPerf_Role];
    [_roleSelector selectItemWithTitle:roleStr];
    
    NSString* useUDPStr = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_iPerf_UseUDP];
    if ([useUDPStr isEqualToString:@"YES"]) {
        _useUDPCheck.checked = YES;
    }else{
        _useUDPCheck.checked = NO;
    }
    
    NSString* portStr = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_iPerf_Port];
    [_portTF setStringValue:portStr];
    
    NSString* bandwithStr  = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_iPerf_Bandwith];
    [_bandwithTF   setStringValue:bandwithStr];
    
    NSString* bufferLenStr = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_iPerf_BufferLen];
    [_bufferLenTF  setStringValue:bufferLenStr];
    
    NSString* tradeoffStr = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_iPerf_Tradeoff];
    if ([tradeoffStr isEqualToString:@"YES"]) {
        _tradeoffCheck.checked = YES;
    }else{
        _tradeoffCheck.checked = NO;
    }

    NSString* dualtestStr = [[AMPreferenceManager standardUserDefaults] stringForKey:Preference_iPerf_Dualtest];
    if ([dualtestStr isEqualToString:@"YES"]) {
        _dualtestCheck.checked = YES;
    }else{
        _dualtestCheck.checked = NO;
    }
}



- (void)windowDidLoad {
    [super windowDidLoad];
    
    _iperfConfig = [[AMIPerfConfig alloc] init];
    [self setupUI];
}

- (void)itemSelected:(AMPopUpView*)sender
{
    if (sender == self.roleSelector) {
        BOOL clientEnable = [self.roleSelector.stringValue isEqualToString:@"CLIENT"];
        
        [_tradeoffCheck setEnabled:clientEnable];
        [_dualtestCheck setEnabled:clientEnable];
    }
}


- (void) setupUI
{
    [AMButtonHandler changeTabTextColor:self.saveButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.cancelButton toColor:UI_Color_blue];
    [self.saveButton.layer      setBorderWidth:1.0];
    [self.saveButton.layer      setBorderColor:UI_Color_blue.CGColor];
    [self.cancelButton.layer    setBorderWidth:1.0];
    [self.cancelButton.layer    setBorderColor:UI_Color_blue.CGColor];
    
    self.roleSelector.delegate = self;
    [self.roleSelector addItemWithTitle:@"SERVER"];
    [self.roleSelector addItemWithTitle:@"CLIENT"];
    
    _useUDPCheck.title = @"UDP";
    _tradeoffCheck.title = @"TRADEOFF";
    _dualtestCheck.title = @"DUAL TEST";
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    
    [self loadDefaultPreference];
}

- (IBAction)closeClicked:(id)sender {
    [self.window close];
}

- (void) updateIPerfConfig
{
    _iperfConfig.serverRole = [self.roleSelector.stringValue isEqualTo:@"SERVER"];
    _iperfConfig.useUDP =[_useUDPCheck checked];
    
    if ([_portTF integerValue] > 0) {
        _iperfConfig.port = [_portTF integerValue];
    }
    
    if ([self.bandwithTF integerValue] > 0) {
        _iperfConfig.bandwith = [self.bandwithTF integerValue];
    }

    if ([self.bufferLenTF integerValue] > 0) {
        _iperfConfig.len = [self.bufferLenTF integerValue];
    }
    
    if ([self.roleSelector.stringValue isEqualTo:@"SERVER"]) {
        _iperfConfig.tradeoff = NO;
        _iperfConfig.dualtest = NO;
    }else{
        _iperfConfig.tradeoff = [_tradeoffCheck checked];
        _iperfConfig.dualtest = [_dualtestCheck checked];
    }
}

- (IBAction)saveClicked:(id)sender {
    [self updateIPerfConfig];
    if (_iperfConfig.serverRole == YES) {
        [[NSNotificationCenter defaultCenter] postNotificationName:AMIPerfServerStartNotification object:nil];
    }
    [self saveDefaultPreference];
    [self.window close];
}


@end
