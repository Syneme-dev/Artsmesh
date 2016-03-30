//
//  AMSyphonManager.h
//  SyphonDemo
//
//  Created by WhiskyZed on 11/19/14.
//  Copyright (c) 2014 WhiskyZed. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMSyphonTearOffController.h"
#import "AMSyphonViewRouterController.h"
#import "AMSyphonViewController.h"
#import "AMP2PViewController.h"
#import "AMSyphonView.h"

@interface AMP2PViewManager : NSObject
-(id)initWithClientCount:(NSUInteger) cnt;
-(NSView*)clientViewByIndex:(NSUInteger)index;
-(BOOL)startRouter;
-(void)stopRouter;
-(void)stopAll;
@end

@interface AMSyphonName : NSObject
+(NSString*) AMRouterName;
+(BOOL)      isSyphonCamera:(NSString*)name;
+(BOOL)     isSyphonRouter:(NSString*)name;
@end

@interface AMSyphonManager : NSObject

-(id)initWithClientCount:(NSUInteger) cnt;

-(NSView*)clientViewByIndex:(NSUInteger)index;
-(NSView*)outputView;
-(NSView*)tearOffView;
-(void)selectClient:(NSUInteger)index;
-(BOOL)startRouter;
-(void)stopRouter;
-(void)stopAll;

-(BOOL)isSyphonServerStarted;

@end
