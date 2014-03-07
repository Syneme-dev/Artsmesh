//
//  AMETCDApi.h
//  HttpAndJson
//
//  Created by 王 为 on 2/27/14.
//  Copyright (c) 2014 王 为. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMETCDResult.h"

@interface AMETCD : NSObject

@property NSString* leaderAddr;
@property NSString* nodeIp;
@property int serverPort;
@property int clientPort;
@property NSString* nodeName;

//If we don't assign parameters, the command will be:
//etcd  -peer-addr 192.168.1.101:7001
//      -addr 192.168.1.101:4001
//      -data-dir machineName
//      -name machienName
-(id)init;

-(BOOL)startETCD;

-(void)stopETCD;

-(AMETCDResult*)getKey:(NSString*)key;

-(AMETCDResult*)setKey:(NSString*)key withValue:(NSString*)value;

-(AMETCDResult*)watchKey:(NSString*)key
                   fromIndex:(int)index_in
                acturalIndex:(int*)index_out
                     timeout:(int)seconds;

-(AMETCDResult*)deleteKey: (NSString*) Key;


@end
