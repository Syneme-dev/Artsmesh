//
//  AMUpdateUserOperation.h
//  AMMesher
//
//  Created by Wei Wang on 5/26/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMMesherOperation.h"

@interface AMUpdateUserOperation : AMMesherOperation

@property NSString* serverPort;
@property NSString* serverAddress;

-(id)initWithServerAddr:(NSString*)addr withPort:(NSString*)port;

@end
