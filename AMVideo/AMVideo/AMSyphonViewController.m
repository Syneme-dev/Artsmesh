//
//  AMSyphonViewController.m
//  SyphonDemo
//
//  Created by WhiskyZed on 11/16/14.
//  Copyright (c) 2014 WhiskyZed. All rights reserved.
//

#import "AMSyphonViewController.h"
#import "AMSyphonView.h"

NSString* kNonServer = @"    --    ";

@interface AMSyphonViewController ()
@property (weak) IBOutlet AMSyphonView *glView;
@property (weak) IBOutlet NSPopUpButton *serverNamePopUpButton;

@end

@implementation AMSyphonViewController
{
    NSArray*        servers;
    SyphonClient*   _syClient;
    
    NSTimeInterval fpsStart;
    NSUInteger fpsCount;
    NSUInteger FPS;
    NSUInteger frameWidth;
    NSUInteger frameHeight;
}

- (void)viewDidLoad {
    // [super viewDidLoad];
    // Do view setup here
    
    [self updateServerList];
}

-(void)updateServerList
{
    [self.serverNamePopUpButton removeAllItems];
    [self.serverNamePopUpButton addItemWithTitle:kNonServer];
    [self.serverNamePopUpButton addItemsWithTitles:[self syphonServerNames]];
}

-(NSArray*)syphonServerNames
{
    NSMutableArray* serverNames = [[NSMutableArray alloc] init];
    
    for (NSDictionary* dict in [SyphonServerDirectory sharedDirectory].servers) {
        NSString* appName   = [dict objectForKey:SyphonServerDescriptionAppNameKey];
        NSString* name      = [dict objectForKey:SyphonServerDescriptionNameKey];
        NSString* title     = [NSString stringWithString:appName];
        
        if([appName isEqualToString:@"Artsmesh"])
        {
            continue;
        }
        
        // A server may not have a name (usually if it is the only server in an application)
        if([name length] > 0) {
            title = [name stringByAppendingFormat:@"-%@", title, nil];
            [serverNames addObject:title];
        }
    }
    
    return serverNames;
}










/*
NSArray* serversNow = [[SyphonServerDirectory sharedDirectory] servers];

if( ![servers isEqualToArray:serversNow]){
    
    servers = serversNow;
    
    NSString* name      = nil;
    
    NSString* appName   = nil;
    
    NSString* title     = nil;
    
    
    
    [self.serverNamePopUpButton removeAllItems];
    
    [serversByTitle removeAllObjects];
    
    
    
    for (NSDictionary* serverInfo in servers) {
        
        name    = [serverInfo objectForKey:SyphonServerDescriptionNameKey];
        
        appName = [serverInfo objectForKey:SyphonServerDescriptionAppNameKey];
        
        title   = [NSString stringWithString:appName];
        
        
        
        // A server may not have a name (usually if it is the only server in an application)
        
        if([name length] > 0) {
            
            title = [name stringByAppendingFormat:@" - %@", title, nil];
            
        }
        
        
        
        [self.serverNamePopUpButton addItemWithTitle:title];
        
        [serversByTitle setObject:serverInfo forKey:title];
        
    }
    
}
*/




-(NSDictionary*)syphonServerDisctriptByName:(NSString*) selectedName
{
    NSDictionary* serverDescript = nil;
    for (NSDictionary* dict in [SyphonServerDirectory sharedDirectory].servers) {
        NSString* appName   = [dict objectForKey:SyphonServerDescriptionAppNameKey];
        NSString* name      = [dict objectForKey:SyphonServerDescriptionNameKey];
        NSString* title     = [NSString stringWithString:appName];
        
        // A server may not have a name (usually if it is the only server in an application)
        if([name length] > 0) {
            title = [name stringByAppendingFormat:@"-%@", title, nil];
        }

        if ([title isEqualToString:title]) {
            serverDescript = dict;
        }
    }
    
    return serverDescript;
}


-(void)stop
{
    self.currentServerName = kNonServer;
    [_syClient stop];
    _syClient = nil;
}

- (IBAction)serverSelected:(NSPopUpButton *)sender
{
    [self stop ];
    if ([sender.selectedItem.title isEqualToString:kNonServer]) {
        return;
    }
    
    NSDictionary* serverDesctipt = [self syphonServerDisctriptByName:sender.selectedItem.title];
    if (!serverDesctipt) {
        return;
    }
    
    // Reset our terrible FPS display
    fpsStart = [NSDate timeIntervalSinceReferenceDate];
    fpsCount = 0;
    FPS = 0;
    
    _syClient = [[SyphonClient alloc] initWithServerDescription:serverDesctipt options:nil newFrameHandler:^(SyphonClient *client) {
        // This gets called whenever the client receives a new frame.
        
        // The new-frame handler could be called from any thread, but because we update our UI we have
        // to do this on the main thread.
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // First we track our framerate...
            fpsCount++;
            float elapsed = [NSDate timeIntervalSinceReferenceDate] - fpsStart;
            if (elapsed > 1.0)
            {
                FPS = ceilf(fpsCount / elapsed);
                fpsStart = [NSDate timeIntervalSinceReferenceDate];
                fpsCount = 0;
            }
            // ...then we check to see if our dimensions display or window shape needs to be updated
//            SyphonImage *frame = [client newFrameImageForContext:[[self.glView openGLContext] CGLContextObj]];
            
            // ...then mark our view as needing display, it will get the frame when it's ready to draw
            [self.glView setNeedsDisplay:YES];
        }];
    }];
    
    if (_syClient == nil)
    {
        frameWidth = 0;
        frameHeight = 0;
        [self.glView setNeedsDisplay:YES];
        return;
    }
    
    [self.glView setSyClient:_syClient];
    self.currentServerName = sender.selectedItem.title;
}


@end
