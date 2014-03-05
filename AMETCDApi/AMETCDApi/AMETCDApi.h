//
//  AMETCDApi.h
//  HttpAndJson
//
//  Created by 王 为 on 2/27/14.
//  Copyright (c) 2014 王 为. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMETCDCURDResult.h"

@interface AMETCDApi : NSObject

@property NSString* serverAddr;


-(AMETCDCURDResult*)getKey:(NSString*)key;

-(AMETCDCURDResult*)setKey:(NSString*)key withValue:(NSString*)value;

-(AMETCDCURDResult*)watchKey:(NSString*)key
                   fromIndex:(int)index_in
                acturalIndex:(int*)index_out
                     timeout:(int)seconds;

-(AMETCDCURDResult*)deleteKey: (NSString*) Key;






@end
