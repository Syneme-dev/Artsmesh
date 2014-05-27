//
//  AMUpdateUserOperation.h
//  AMMesher
//
//  Created by Wei Wang on 5/26/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMMesherOperation.h"

@class AMUserUDPResponse;
@class AMUserUDPRequest;
@interface AMUpdateUserOperation : AMMesherOperation

@property NSString* serverPort;
@property NSString* serverAddress;
@property AMUserUDPRequest* udpRequest;
@property AMUserUDPResponse* udpResponse;

-(id)initWithServerAddr:(NSString*)addr withPort:(NSString*)port;

@end
