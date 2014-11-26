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
    NSMutableDictionary*  _syServers;
    SyphonClient*  _syClient;
    NSMutableDictionary* _processCounter;
    
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
    _syServers = [[NSMutableDictionary alloc] init];
    _processCounter = [[NSMutableDictionary alloc] init];
    
    for (NSDictionary* dict in [SyphonServerDirectory sharedDirectory].servers) {
        NSString* appName   = [dict objectForKey:SyphonServerDescriptionAppNameKey];
        NSString* name      = [dict objectForKey:SyphonServerDescriptionNameKey];
        NSString* title     = [NSString stringWithString:appName];
        
        if([appName isEqualToString:@"Artsmesh"])
        {
            //filter self server
            continue;
        }
        
        //Add appName to a dict for ref count
        NSNumber* newNumber;
        NSNumber* number = [_processCounter objectForKey:appName];
        if (number != nil) {
            newNumber = [NSNumber numberWithInt: [number intValue] + 1];
        }else{
            newNumber = [NSNumber numberWithInt:1];
        }
        
        [_processCounter setObject:newNumber forKey:appName];
        
        // A server may not have a name (usually if it is the only server in an application)
        if([name length] > 0) {
            title = [name stringByAppendingFormat:@"-%@", title, nil];
        }
    
        if ([_syServers objectForKey:title] != nil) {
            
            NSArray* paths = [title componentsSeparatedByString:@"-"];
            NSString* lastPath = [paths lastObject];
            
            NSScanner* scan = [NSScanner scannerWithString:lastPath];
            int val;
            BOOL isInt = [scan scanInt:&val] && [scan isAtEnd];
            
            if (isInt) {
                NSString* titleBody = [title substringToIndex:title.length - lastPath.length - 1];
                title = [NSString stringWithFormat:@"%@%@", titleBody, newNumber];
                
            }else{
                title = [NSString stringWithFormat:@"%@-%@", title, newNumber];
            }
        }
        
        [_syServers setObject:dict forKey:title];
        [serverNames addObject:title];
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
    return [_syServers objectForKey:selectedName];
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
            SyphonImage *frame = [client newFrameImageForContext:[[self.glView openGLContext] CGLContextObj]];
            
             self.glView.image = frame;
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
    
    self.currentServerName = sender.selectedItem.title;
}


@end
