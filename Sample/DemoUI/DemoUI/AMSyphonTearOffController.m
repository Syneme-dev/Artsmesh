//
//  AMSyphonTearOffController.m
//  DemoUI
//
//  Created by whiskyzed on 12/7/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMSyphonTearOffController.h"
#import "AMSyphonViewPopUp.h"

@interface AMSyphonTearOffController ()
@property (weak) IBOutlet AMSyphonViewPopUp *glView;


@end

@implementation AMSyphonTearOffController
{
     SyphonClient*           _syClient;
    NSTimeInterval fpsStart;
    NSUInteger fpsCount;
    NSUInteger FPS;
    NSUInteger frameWidth;
    NSUInteger frameHeight;

}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

-(void)stop
{
    
    [_syClient stop];
    _syClient = nil;
}

- (void)selectNewServer:(NSDictionary *) aServer
{
    [self stop ];
   
    
    // Reset our terrible FPS display
    fpsStart = [NSDate timeIntervalSinceReferenceDate];
    fpsCount = 0;
    FPS = 0;

    
    _syClient = [[SyphonClient alloc] initWithServerDescription:aServer options:nil newFrameHandler:^(SyphonClient *client) {
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
            
            [self.glView drawRect:self.glView.bounds];
            
            //[self.glView setNeedsDisplay:YES];
        }];
    }];
    
    if (_syClient == nil)
    {
        frameWidth = 0;
        frameHeight = 0;
  //      [self.glView setNeedsDisplay:YES];
        return;
    }
    
   // self.currentServerName = sender.selectedItem.title;
}



@end
