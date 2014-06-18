//
//  AMRemoteMesher.h
//  AMMesher
//
//  Created by Wei Wang on 6/16/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMRemoteMesher : NSObject

-(id)initWithServer:(NSString*)ip
               port:(NSString*)port
        userTimeout:(int)seconds
               ipv6:(BOOL)useIpv6;

-(void)startRemoteClient;
-(void)stopRemoteClient;

-(void)mergeGroup:(NSString*)superGroupId;
-(void)unmergeGroup;

@end
