//
//  AMMesherOperationProtocol.h
//  AMMesher
//
//  Created by Wei Wang on 3/31/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AMETCDLauncher;
@class AMETCDInitializer;
@class AMAddUserOperator;
@class AMRemoveUserOperator;
@class AMUpdateUserOperator;
@class AMQueryAllOperator;

@protocol AMMesherOperationProtocol <NSObject>

- (void)ETCDLauncherDidFinish:(AMETCDLauncher *)launcher;
- (void)ETCDInitializerDidFinish:(AMETCDInitializer *)initializer;
- (void)AddUserOperatorDidFinish:(AMAddUserOperator *)addOper;
- (void)RemoveUserOperatorDidFinish:(AMRemoveUserOperator *)removeOper;
- (void)UpdateUserOperatorDidFinish:(AMUpdateUserOperator *)UpdataOper;
- (void)QueryAllOperatorDidFinish:(AMQueryAllOperator *)queryOper;

@end
