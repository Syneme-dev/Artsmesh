//
//  AMMesher.h
//  AMMesher
//
//  Created by Wei Wang on 3/18/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AMMesher : NSObject
{
    NSString* myGroupName;
    NSString* myUserName;
    NSString* myDomain;
    NSString* myDescription;
    NSString* myStatus;
    NSString* myIp;
    NSMutableArray* groups;
}

-(NSString*)myGroupName;
-(void)setMyGroupName:(NSString*)name;

-(NSString*)myUserName;
-(void)setMyUserName;

-(NSString*)myDomain;
-(void)setMyDomain;

-(NSString*)myDescription;
-(void)setMyDescription;

-(NSString*)myStatus;
-(void)getMyStatus;

-(NSString*)myIp;
-(void)setMyIP;

+(dispatch_queue_t) get_mesher_serial_query_queue;
+(dispatch_queue_t) get_mesher_serial_update_queue;

-(void)startLoalMesher;
-(void)stopLocalMesher;

@end
