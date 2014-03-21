//
//  AMUserGroupServerDelegate.h
//  UserGroupModule
//
//  Created by Wei Wang on 3/21/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCDAsyncUdpSocket;
@protocol AMUserGroupServerDelegate <NSObject>

-(void)GetGroupsHandler:(GCDAsyncUdpSocket*)sock
            fromAddress:(NSData *)address
            withRequest:(NSString*)request;


-(void)GetUsersHandler:(GCDAsyncUdpSocket*)sock
           fromAddress:(NSData *)address
           withRequest:(NSString*)request;

-(void)RegisterUserHandler:(GCDAsyncUdpSocket*)sock
               fromAddress:(NSData *)address
               withRequest:(NSString*)request
                  username:(NSString*)name
                   usePort:(int)port;


-(void)UnregisterUserHandler:(GCDAsyncUdpSocket*)sock
               fromAddress:(NSData *)address
               withRequest:(NSString*)request
                    username:(NSString*)name;

@end
