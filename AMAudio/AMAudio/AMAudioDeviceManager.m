//
//  AMAudioDeviceManager.m
//  AMAudio
//
//  Created by 王 为 on 8/22/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMAudioDeviceManager.h"
#import "AMLogger/AMLogger.h"

typedef	UInt8 CAAudioHardwareDeviceSectionID;
#define	kAudioDeviceSectionGlobal	((CAAudioHardwareDeviceSectionID)0x00)

static UInt32	sNumberCommonSampleRates = 15;
static Float64	sCommonSampleRates[] = {	  8000.0,  11025.0,  12000.0,
    16000.0,  22050.0,  24000.0,
    32000.0,  44100.0,  48000.0,
    64000.0,  88200.0,  96000.0,
    128000.0, 176400.0, 192000.0 };

@implementation AMAudioDeviceManager
{
    NSMutableArray* _audioDevices;
}


-(id)init
{
    if (self = [super init]) {
        [self loadDevices];
    }
    
    return self;
}


-(NSArray*)inputDevices
{
    if (_audioDevices == nil) {
        [self loadDevices];
    }
    
    NSMutableArray* inputDevices = [[NSMutableArray alloc] init];
    for(AMAudioDevice* dev in _audioDevices){
        if(dev.inChannels > 0){
            [inputDevices addObject:dev];
        }
    }
    
    return inputDevices;
}

-(NSArray*)outputDevices
{
    if (_audioDevices == nil) {
        [self loadDevices];
    }
    
    NSMutableArray*outputDevices = [[NSMutableArray alloc] init];
    for(AMAudioDevice* dev in _audioDevices){
        if(dev.outChanels > 0){
            [outputDevices addObject:dev];
        }
    }
    
    return outputDevices;
}


-(AMAudioDevice*)findDevByName:(NSString*)devName
{
    for (AMAudioDevice* dev in _audioDevices) {
        if ([dev.devName isEqualToString:devName]) {
            return dev;
        }
    }
    
    return nil;
}

-(AMAudioDevice*)findDevByUID:(NSString *)devUID
{
    for (AMAudioDevice* dev in _audioDevices) {
        if ([dev.devUID isEqualToString:devUID]) {
            return dev;
        }
    }
    
    return nil;
}


-(AMAudioDevice*)defaultInputDevice
{
    AudioDeviceID defaultInputDevId = -1;
    int size = sizeof(AudioDeviceID);
    OSStatus err = AudioHardwareGetProperty(kAudioHardwarePropertyDefaultInputDevice, &size, &defaultInputDevId);
    if (err != noErr){
        NSLog(@"audio get default input device error, error code=%d,", err);
    }
    
    NSArray* devices = [self inputDevices];
    for (AMAudioDevice* dev in devices) {
        if (dev.devId  == defaultInputDevId) {
            return dev;
        }
    }
    
    return nil;
}


-(AMAudioDevice*)defaultOutputDevice
{
    AudioDeviceID defaultOutputDevId = -1;
    int size = sizeof(AudioDeviceID);
    
    OSStatus err = AudioHardwareGetProperty(kAudioHardwarePropertyDefaultOutputDevice, &size, &defaultOutputDevId);
    if (err != noErr){
        NSLog(@"audio get default output device error, error code=%d,", err);
    }
    
    NSArray* devices = [self outputDevices];
    for (AMAudioDevice* dev in devices) {
        if (dev.devId  == defaultOutputDevId) {
            return dev;
        }
    }
    
    return nil;
}


- (void)loadDevices
{
    AMLog(kAMInfoLog, @"AMAudio", @"GetDevNames");
    
    UInt32 size;
    Boolean isWritable;
    OSStatus err = AudioHardwareGetPropertyInfo(kAudioHardwarePropertyDevices, &size, &isWritable);
    if (err != noErr) {
        _audioDevices = nil;
        return;
    }
    
    int numberOfDevs = size/sizeof(AudioDeviceID);
	AMLog(kAMInfoLog, @"AMAudio", @"Number of audio devices = %d", numberOfDevs);
    
    AudioDeviceID allDevices[numberOfDevs];
    err = AudioHardwareGetProperty(kAudioHardwarePropertyDevices, &size, allDevices);
    if (err != noErr){
        _audioDevices = nil;
		return;
    }
    
    for (int i = 0; i < numberOfDevs; i++) {
		char name[256];
		CFStringRef nameRef;
		size = sizeof(CFStringRef);
		err = AudioDeviceGetProperty(allDevices[i], 0, false, kAudioDevicePropertyDeviceNameCFString, &size, &nameRef);
        if (err != noErr){
            CFRelease(nameRef);
			continue;
        }
        
		CFStringGetCString(nameRef, name, 256, kCFStringEncodingMacRoman);
		AMLog(kAMInfoLog, @"AMAudio", @"Checking device = %s\n", name);
		
        //don't add JackRouter and iSight to device list
     	if (strcmp(name,"JackRouter") != 0 && strcmp(name,"iSight") != 0) {
            int inputChans =  [self getDevInChannels:allDevices[i]];
            int outputChans = [self getDevOutChannels:allDevices[i]];
            if (inputChans == 0 && outputChans == 0) {
                continue;
            }
            
            AMLog(kAMInfoLog, @"AMAudio", @"Adding device = %s\n", name);
            
            NSString* devName = [NSString stringWithCString:name encoding:NSMacOSRomanStringEncoding];
            
            // An Aggregate Device should have inputChans != 0 && outputChans != 0
            if ([self isAggregateDevice:allDevices[i]] && (inputChans == 0 || outputChans == 0)) {
                continue;
            }
            
            //init new device
            AMAudioDevice* newDevice = [[AMAudioDevice alloc] init];
            newDevice.devName = devName;
            newDevice.devId = allDevices[i];
            newDevice.inChannels = 0;
            newDevice.outChanels = 0;
            
            //GetDeviceUID
            char deviceUID[128];
            getDeviceUIDFromID(allDevices[i], deviceUID);
            newDevice.devUID = [NSString stringWithUTF8String:deviceUID];
            
            //Get Channel Numbers
            if (inputChans > 0) {
                newDevice.inChannels = inputChans;
            }
            
            if (outputChans > 0) {
                newDevice.outChanels = outputChans;
            }
            
            //get buffersize selections
            newDevice.bufferSizes = [[NSMutableArray alloc] init];
            
            AudioValueRange inputOutputRange;
            if (inputChans > 0) {
                
                UInt32 size = sizeof(AudioValueRange);
                bool res = getDeviceBufferRange(allDevices[i], true, &size, &inputOutputRange);
                if (!res) {
                    inputOutputRange.mMinimum = 32;
                    inputOutputRange.mMaximum = 4096;
                }
            }
            
            if (outputChans > 0) {
                UInt32 size = sizeof(AudioValueRange);
                AudioValueRange outputRange;
                bool res = getDeviceBufferRange(allDevices[i], true, &size, &outputRange);
                if (res) {
                    if (outputRange.mMaximum < inputOutputRange.mMaximum) {
                        inputOutputRange.mMaximum = outputRange.mMaximum;
                    }else{
                        if (outputRange.mMinimum > inputOutputRange.mMinimum) {
                            inputOutputRange.mMinimum = outputRange.mMinimum;
                        }
                    }
                }
            }
            
            for (int i = 32; i < 65535; i *= 2) {
                if (i >= inputOutputRange.mMinimum && i <= inputOutputRange.mMaximum) {
                    [newDevice.bufferSizes addObject: [NSNumber numberWithInt:i]];
                }
            }
            
            //Get samplerate Selections
            newDevice.sampleRates = [[NSMutableArray alloc] init];
            
            UInt32 size;
            err = AudioDeviceGetPropertyInfo(allDevices[i], 0, true, kAudioDevicePropertyAvailableNominalSampleRates, &size, &isWritable);
            if (err == noErr) {
                int count = size / sizeof(AudioValueRange);
                AudioValueRange valueTable[count];
                err = AudioDeviceGetProperty(allDevices[i], 0, true, kAudioDevicePropertyAvailableNominalSampleRates, &size, valueTable);
                
                for (int i = 0 ; i < count; i ++) {
                    AudioValueRange range = valueTable[i];
                    
                    for (int j = 0; j < sNumberCommonSampleRates; j++) {
                        int sampleRate = sCommonSampleRates[j];
                        if (sampleRate >= range.mMinimum && sampleRate <= range.mMaximum) {
                            [newDevice.sampleRates addObject:[NSNumber numberWithInt:sampleRate]];
                        }
                    }
                }
            }
            
            if (_audioDevices == nil) {
                _audioDevices = [[NSMutableArray alloc] init];
            }
            [_audioDevices addObject:newDevice];
        }
		
		CFRelease(nameRef);
    }
    
    return;
}

#pragma mark-
#pragma private functions

-(int)getDevInChannels:(AudioDeviceID)devId
{
    int inChannels = 0;
    OSStatus err = getTotalChannels(devId, &inChannels, true);
    if (err != noErr) {
		return 0;
	}
    
    return inChannels;
}

-(int)getDevOutChannels:(AudioDeviceID)devId
{
    int outChannels = 0;
    OSStatus err = getTotalChannels(devId, &outChannels, false);
    if (err != noErr) {
		return 0;
	}
    
    return outChannels;
}

-(BOOL)isAggregateDevice:(AudioDeviceID) devId
{
    //NSLog(@"isAggregateDevice\n");
    
    UInt32 deviceType, outSize = sizeof(UInt32);
    OSStatus err = AudioDeviceGetProperty(devId, 0, kAudioDeviceSectionGlobal, kAudioDevicePropertyTransportType, &outSize, &deviceType);
    
    if (err != noErr) {
        NSLog(@"kAudioDevicePropertyTransportType error");
        return NO;
    } else {
        return (deviceType == kAudioDeviceTransportTypeAggregate);
    }
}

static OSStatus getTotalChannels(AudioDeviceID device, UInt32* channelCount, Boolean isInput)
{
    OSStatus			err = noErr;
    UInt32				outSize;
    Boolean				outWritable;
    AudioBufferList*	bufferList = 0;
	unsigned int i;
    
    AMLog(kAMInfoLog, @"AMAudio", @"get total channels");
    
	*channelCount = 0;
    err = AudioDeviceGetPropertyInfo(device, 0, isInput, kAudioDevicePropertyStreamConfiguration, &outSize, &outWritable);
    if (err == noErr) {
        bufferList = (AudioBufferList*)malloc(outSize);
        err = AudioDeviceGetProperty(device, 0, isInput, kAudioDevicePropertyStreamConfiguration, &outSize, bufferList);
        if (err == noErr) {
            for (i = 0; i < bufferList->mNumberBuffers; i++)
                *channelCount += bufferList->mBuffers[i].mNumberChannels;
        } else {
            AMLog(kAMErrorLog, @"AMAudio", @"getTotalChannels : AudioDeviceGetProperty error\n");
        }
		if (bufferList)
			free(bufferList);
    } else {
        AMLog(kAMErrorLog, @"AMAudio", @"getTotalChannels : AudioDeviceGetPropertyInfo error\n");
    }
	return (err);
}

static bool getDeviceBufferRange(AudioDeviceID devId, bool inputDevice, UInt32* size, AudioValueRange* range)
{
    OSStatus err = AudioDeviceGetProperty(devId, 0, inputDevice, kAudioDevicePropertyBufferFrameSizeRange, size, range);
    if (err != noErr) {
        AMLog(kAMErrorLog, @"AMAudio", @"Cannot get buffer size range for input\n");
        return false;
    } else {
        AMLog(kAMInfoLog, @"AMAudio", @"Get buffer size range for input min = %d max = %d\n", (int)(range->mMinimum), (int)(range->mMaximum));
        return true;
    }
}

static OSStatus getDeviceUIDFromID(AudioDeviceID id, char* name)
{
    AMLog(kAMInfoLog, @"AMAudio", @"getDeviceUIDFromID\n");
    
    UInt32 size = sizeof(CFStringRef);
	CFStringRef UI;
    OSStatus res = AudioDeviceGetProperty(id, 0, false, kAudioDevicePropertyDeviceUID, &size, &UI);
	if (res == noErr) {
		CFStringGetCString(UI, name, 128, CFStringGetSystemEncoding());
		AMLog(kAMInfoLog, @"AMAudio", @"getDeviceUIDFromID: name = %s\n", name);
		CFRelease(UI);
	} else {
        name[0] = 0;
		AMLog(kAMErrorLog, @"AMAudio", @"getDeviceUIDFromID: error name = %s\n", name);
	}
    return res;
}


@end
