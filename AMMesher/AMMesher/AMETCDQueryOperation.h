//
//  AMETCDQueryOperation.h
//  AMMesher
//
//  Created by Wei Wang on 4/7/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMETCDOperation.h"

@interface AMETCDQueryOperation : AMETCDOperation

-(id)init:(NSString*)ip
     port:(NSString*)port;

@end
