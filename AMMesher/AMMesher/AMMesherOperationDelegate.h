//
//  AMMesherOperationDelegate.h
//  AMMesher
//
//  Created by xujian on 4/22/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AMMesherOperation;

@protocol AMMesherOperationDelegate <NSObject>

-(void)MesherOperDidFinished:(AMMesherOperation*)oper;

@end
