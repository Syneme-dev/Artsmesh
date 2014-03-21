//
//  AMETCDManager.h
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AMETCDManager : NSObject

-(void)startETCD:(NSDictionary*)params;

-(void)stopETCD;

@end
