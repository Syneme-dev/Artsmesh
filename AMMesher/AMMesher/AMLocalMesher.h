//
//  AMLocalMesher.h
//  AMMesher
//
//  Created by Wei Wang on 6/16/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AMHeartBeatDelegate;

@interface AMLocalMesher : NSObject

-(void)updateMyself;
-(void)changeGroupPassword:(NSString*)newPassword password:(NSString*)oldPassword;

@end
