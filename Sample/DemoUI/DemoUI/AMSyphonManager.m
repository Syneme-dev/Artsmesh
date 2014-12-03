//
//  AMSyphonManager.m
//  SyphonDemo
//
//  Created by WhiskyZed on 11/19/14.
//  Copyright (c) 2014 WhiskyZed. All rights reserved.
//

#import "AMSyphonManager.h"
@implementation AMSyphonManager
{
    NSMutableArray* _syClients;
    AMSyphonViewRouterController* _syServer;
    AMSyphonViewRouterController* _syTearOff;
}

- (id) initWithClientCount : (int) cnt
{
    if(self = [super init]){
        NSBundle* myBundle = [NSBundle bundleWithIdentifier:@"com.artsmesh.videoFramework"];
        
        _syClients = [[NSMutableArray alloc] init];
        for(int i = 0; i < cnt; i++){
            AMSyphonViewController* amSyphonCtrl =  [[AMSyphonViewController alloc]
                                                     initWithNibName:@"AMSyphonViewController" bundle:myBundle];
            [_syClients addObject:amSyphonCtrl];
        }
        
        _syServer = [[AMSyphonViewRouterController alloc] initWithNibName:@"AMSyphonViewRouterController" bundle:myBundle];
        
        _syTearOff = [[AMSyphonViewRouterController alloc] initWithNibName:@"AMSyphonViewRouterController" bundle:myBundle];
        [_syTearOff stopRouter];
        
        [[SyphonServerDirectory sharedDirectory] addObserver:self forKeyPath:@"servers" options:NSKeyValueObservingOptionNew context:nil];
    }

    return self;
}

-(void)dealloc
{
    [[SyphonServerDirectory sharedDirectory] removeObserver:self forKeyPath:@"servers"];
}



#pragma mark -
#pragma   mark KVO
- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context
{
    
    if ([keyPath isEqualToString:@"servers"]){
        for (AMSyphonViewController* client in _syClients) {
            [client updateServerList];
        }
        
        [_syServer updateServerList];
    }
}

-(NSView*)clientViewByIndex:(int)index
{
    if(index >= [_syClients count]){
        return nil;
    }
    AMSyphonViewController* amSyphonCtrl = [_syClients objectAtIndex:index];
    return amSyphonCtrl.view;
}


-(NSView*)outputView
{
    return _syServer.view;
}

- (NSView*) tearOffView
{
    
    return _syTearOff.view;
}

- (BOOL) startRouter
{
    return [_syServer startRouter];
}

- (void) stopRouter
{
    [_syServer  stopRouter];
}

-(void)selectClient:(int)index
{
    if(index >= [_syClients count]){
        return;
    }
    
    AMSyphonViewController* amSyphonCtrl = [_syClients objectAtIndex:index];
    NSString* serverName = [amSyphonCtrl currentServerName];
    [_syServer stop];
    
    if(serverName != nil){
        _syServer.currentServerName = serverName;
        [_syServer start];
        
        //tearOff
        _syTearOff.currentServerName = serverName;
        [_syTearOff start];
    }
}


-(BOOL)isSyphonServerStarted;
{
    return [_syServer routing];
}

@end
