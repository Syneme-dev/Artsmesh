//
//  AMAudio.m
//  AMAudio
//
//  Created by 王 为 on 8/22/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMAudio.h"
#import "AMAudioPrefViewController.h"

@implementation AMAudio
{
    AMAudioPrefViewController* _prefController;
}

-(NSViewController*)getPreferenceUI
{
    if (_prefController == nil) {
        _prefController = [[AMAudioPrefViewController alloc] initWithNibName:@"AMAudioPrefViewController" bundle:nil];
    }
    
    return _prefController;
}

@end
