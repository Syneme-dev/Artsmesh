//
//  AMJackTripManager.h
//  AMAudio
//
//  Created by 王 为 on 9/10/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMJackTripManager : NSObject

@property NSMutableArray* jackTripInstances;

-(void)stopAllJacktrips;

@end
