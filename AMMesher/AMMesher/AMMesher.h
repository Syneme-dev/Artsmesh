//
//  AMMesher.h
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AMMesher : NSObject

@property NSString* myGroupName;
@property NSString* myUserName;
@property NSString* myDomain;
@property NSString* myDescription;
@property NSString* myStatus;
@property NSString* myIp;

+(dispatch_queue_t) mesher_serial_queue;
-(void)startLoalMesher;
-(void)stopLocalMesher;

@end
