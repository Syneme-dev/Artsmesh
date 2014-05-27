//
//  AMRequestUserOperation.h
//  AMMesher
//
//  Created by Wei Wang on 5/26/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import "AMMesherOperation.h"

@class AMUserRESTResponse;
@interface AMRequestUserOperation : AMMesherOperation

@property NSString* mesherSeverURL;
@property AMUserRESTResponse* restResponse;

-(id)initWithMesherServerUrl:(NSString*)mesherServerURL;

@end
