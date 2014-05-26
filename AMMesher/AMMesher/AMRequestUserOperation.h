//
//  AMRequestUserOperation.h
//  AMMesher
//
//  Created by Wei Wang on 5/26/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMMesherOperation.h"

@interface AMRequestUserOperation : AMMesherOperation

@property NSString* mesherSeverURL;

-(id)initWithMesherServerUrl:(NSString*)mesherServerURL;

@end
