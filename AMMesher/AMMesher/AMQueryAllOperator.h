//
//  AMQueryAllOperator.h
//  AMMesher
//
//  Created by Wei Wang on 3/30/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMMesherOperationProtocol.h"



@interface AMQueryAllOperator : NSOperation

@property id <AMMesherOperationProtocol> delegate;
@property (readonly) BOOL isResultOK;
@property NSMutableArray* usergroups;


-(id)initWithParameter:(NSString*)hostAddr
            serverPort:(NSString*)cp
              delegate:(id<AMMesherOperationProtocol>)delegate;

@end
