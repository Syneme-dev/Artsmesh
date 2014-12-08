//
//  AMJackPort.h
//  JackClient
//
//  Created by wangwei on 8/11/14.
//  Copyright (c) 2014 王为. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <jack/jack.h>

typedef enum _AMJackPortType{
    AMJackPort_Source,
    AMJackPort_Destination
}AMJackPortType;

@interface AMJackPort : NSObject

@property NSString* name;
@property AMJackPortType portType;

@property float volume;
@property float tempPeak;

@property jack_port_t *port_handle;

@end
