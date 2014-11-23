//
//  AMSyphonManager.h
//  SyphonDemo
//
//  Created by WhiskyZed on 11/19/14.
//  Copyright (c) 2014 WhiskyZed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMSyphonViewRouterController.h"
#import "AMSyphonViewController.h"
#import "AMSyphonView.h"

@interface AMSyphonManager : NSObject

-(id)initWithClientCount:(int) cnt;

-(NSView*)clientViewByIndex:(int)index;
-(NSView*)outputView;
-(void)selectClient:(int)index;
-(BOOL)startRouter;
-(void)stopRouter;

-(BOOL)isSyphonServerStarted;

@end
