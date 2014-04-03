//
//  AMMesherAgent.h
//  AMMesher
//
//  Created by 王 为 on 4/3/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AMMesherOperationProtocol;
@interface AMMesherAgent : NSObject<AMMesherOperationProtocol>

-(void)goOnline;

@end
