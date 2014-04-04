//
//  AMMesherOperationProtocol.h
//  AMMesher
//
//  Created by Wei Wang on 3/31/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AMMesherOperationProtocol <NSObject>

- (void)LanchETCDOperationDidFinish:(NSOperation *)oper;
- (void)InitETCDOperationDidFinish:(NSOperation *)oper;

- (void)AddGroupOperationDidFinish:(NSOperation*)oper;
- (void)DeleteGroupOperationDidFinish:(NSOperation*)oper;
- (void)UpdateGroupOperationDidFinish:(NSOperation*)oper;
- (void)QueryGroupsOperationDidFinish:(NSOperation *)oper;
- (void)AddUserOperationDidFinish:(NSOperation *)oper;
- (void)DeleteUserOperationDidFinish:(NSOperation *)oper;
- (void)UpdateUserOperationDidFinish:(NSOperation *)oper;

@end
