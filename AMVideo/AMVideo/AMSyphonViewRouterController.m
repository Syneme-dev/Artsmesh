//
//  AMSyphonViewRouterController.m
//  SyphonDemo
//
//  Created by WhiskyZed on 11/19/14.
//  Copyright (c) 2014 WhiskyZed. All rights reserved.
//

#import "AMSyphonViewRouterController.h"
#import "AMSyphonView.h"
#import "Syphon/Syphon.h"

@interface AMSyphonViewRouterController ()
@property (weak) IBOutlet AMSyphonView *glView;


@end

@implementation AMSyphonViewRouterController

- (void)viewDidLoad {
//    [super viewDidLoad];
    // Do view setup here.
}


- (void) awakeFromNib
{
    CGLContextObj context = [[self.glView openGLContext] CGLContextObj];
    syRouter = [[SyphonServer alloc] initWithName:@"AMSyphonRouter" context:context options:nil];
    
}

- (void)startVideo{
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
            
            //routering
            if(routering){
                [syRouter publishFrameTexture:frame.textureName
                                textureTarget:GL_TEXTURE_RECTANGLE_EXT
                                  imageRegion:NSMakeRect(0, 0, frame.textureSize.width, frame.textureSize.height)
                            textureDimensions:frame.textureSize
                                      flipped:NO];

            }
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
    servers = [[SyphonServerDirectory sharedDirectory] servers];
}

- (BOOL) startRouter:(NSString *)err
{
    routering   = YES;
    [self UpdateServerInfo];
    [self startVideo];
 //   [syServer startRouter];
    return YES;
}
- (BOOL) stopRouter:(NSString *)err
{
    routering  = NO;
    [syRouter stop];
    
    return YES;
}
@end
