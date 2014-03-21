//
//  AMETCDServiceInterface.h
//  AMMesher
//
//  Created by Wei Wang on 3/22/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AMETCDServiceInterface <NSObject>

-(void)startService:(NSDictionary*)params reply:(void(^)(NSString*))reply;

-(void)stopService;

@end
