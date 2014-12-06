//
//  AMSyphonViewRouterController.h
//  SyphonDemo
//
//  Created by WhiskyZed on 11/19/14.
//  Copyright (c) 2014 WhiskyZed. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Syphon/Syphon.h>

@interface AMSyphonViewRouterController : NSViewController

@property BOOL routing;
@property NSString* currentServerName;

-(void)updateServerList;

-(BOOL)start;
-(void)stop;

- (BOOL) startRouter;
- (void) stopRouter;

@end
