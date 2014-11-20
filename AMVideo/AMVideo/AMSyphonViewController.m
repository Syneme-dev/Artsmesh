//
//  AMSyphonViewController.m
//  SyphonDemo
//
//  Created by WhiskyZed on 11/16/14.
//  Copyright (c) 2014 WhiskyZed. All rights reserved.
//

#import "AMSyphonViewController.h"
#import "AMSyphonView.h"
@interface AMSyphonViewController ()
@property (weak) IBOutlet AMSyphonView *glView;
@property (weak) IBOutlet NSPopUpButton *serverNamePopUpButton;

@end

@implementation AMSyphonViewController

- (void)viewDidLoad {
//    [super viewDidLoad];
    // Do view setup here.
}

#pragma     mark -
#pragma     mark KVO
- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context
{
    if ([object isKindOfClass:[SyphonServerDirectory class]]){
        
        if ([keyPath isEqualToString:@"servers"]){
            [self UpdateServerInfo];
        }
    }
}

- (void) awakeFromNib
{
//    [[SyphonServerDirectory sharedDirectory] addObserver:self forKeyPath:@"servers"
//                                   options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
//                                   context:nil];
    
    [self UpdateServerInfo];
}

- (IBAction)startVideo:(id)sender {
    [syClient stop];
    
    // Reset our terrible FPS display
    fpsStart = [NSDate timeIntervalSinceReferenceDate];
    fpsCount = 0;
    FPS = 0;
    syClient = [[SyphonClient alloc] initWithServerDescription:[servers lastObject] options:nil newFrameHandler:^(SyphonClient *client) {
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
            
            // ...then mark our view as needing display, it will get the frame when it's ready to draw
            [self.glView setNeedsDisplay:YES];
        }];
    }];
    
    // Our view uses the client to draw, so keep it up to date
    [self.glView setSyClient:syClient];
    
    // If we have a client we do nothing - wait until it outputs a frame
    
    // Otherwise clear the view
    if (syClient == nil)
    {
        frameWidth = 0;
        frameHeight = 0;
        [self.glView setNeedsDisplay:YES];
    }
}

-(void) UpdateServerInfo
{
    [self.serverNamePopUpButton removeAllItems];
    NSArray* serversNow = [[SyphonServerDirectory sharedDirectory] servers];
    if( ![servers isEqualToArray:serversNow]){
        servers = serversNow;
        for (NSDictionary* serverInfo in servers) {
            [self.serverNamePopUpButton addItemWithTitle:[serverInfo valueForKey:@"SyphonServerDescriptionAppNameKey"]];
        }
    }
}


@end
