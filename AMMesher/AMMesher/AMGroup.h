//
//  AMGroup.h
//  AMMesher
//
//  Created by 王 为 on 3/27/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMGroup : NSObject

@property NSString* name;
@property NSString* domain;
@property NSString* description;
@property NSString* m2mIp; //mesher to mesher ip
@property NSString* m2mPort;
@property NSString* foafUrl;

@property NSMutableArray* users;

@end
