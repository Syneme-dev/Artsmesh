//
//  AMETCDSyncInterface.h
//  AMMesher
//
//  Created by Wei Wang on 3/22/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AMETCDSyncInterface <NSObject>

-(void)setTestIntVal:(int)s;

-(void)getTestIntVal:(void(^)(int))reply;

-(void)startSync:(NSString*)ip port:(int)p;

-(void)stopSync;

@end
