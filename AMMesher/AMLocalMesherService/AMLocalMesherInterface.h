//
//  AMLocalMesherInterface.h
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AMLocalMesherInterface <NSObject>

-(void)startSvc:(NSDictionary*)params reply:(void(^)(NSString*))reply;

-(void)stopSvc;

@end
