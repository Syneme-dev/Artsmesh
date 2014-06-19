//
//  AMRemoteMesher.h
//  AMMesher
//
//  Created by Wei Wang on 6/16/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMRemoteMesher : NSObject

-(void)startRemoteClient;
-(void)stopRemoteClient;

-(void)mergeGroup:(NSString*)superGroupId;
-(void)unmergeGroup;

@end
