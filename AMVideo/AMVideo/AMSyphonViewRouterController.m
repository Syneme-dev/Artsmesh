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
{
    SyphonClient*   _syClient;
    SyphonServer*   _syRouter;
    
    NSTimeInterval fpsStart;
    NSUInteger fpsCount;
    NSUInteger FPS;
    NSUInteger frameWidth;
    NSUInteger frameHeight;
}

- (void)viewDidLoad {
//    [super viewDidLoad];
    // Do view setup here.
}

-(NSDictionary*)syphonServerDisctriptByName:(NSString*)name
{
    NSDictionary* serverDescript = nil;
    for (NSDictionary* dict in [SyphonServerDirectory sharedDirectory].servers) {
        NSString* str = [dict objectForKey:SyphonServerDescriptionAppNameKey];
        
        if ([str isEqualToString:name]) {
            serverDescript = dict;
        }
    }
    
    return serverDescript;
}


-(BOOL)start
{
    if(self.currentServerName == nil){
        return NO;
    }
    
    NSDictionary* serverDescript = [self syphonServerDisctriptByName:self.currentServerName];
    if (serverDescript == nil) {
        return NO;
    }
    
    // Reset our terrible FPS display
    fpsStart = [NSDate timeIntervalSinceReferenceDate];
    fpsCount = 0;
    FPS = 0;
    
    _syClient = [[SyphonClient alloc] initWithServerDescription:serverDescript options:nil newFrameHandler:^(SyphonClient *client) {
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
            if(self.routing){
                [_syRouter publishFrameTexture:frame.textureName
                                textureTarget:GL_TEXTURE_RECTANGLE_EXT
                                  imageRegion:NSMakeRect(0, 0, frame.textureSize.width, frame.textureSize.height)
                            textureDimensions:frame.textureSize
                                      flipped:NO];
                
            }
            // ...then mark our view as needing display, it will get the frame when it's ready to draw
            [self.glView setNeedsDisplay:YES];
        }];
    }];
    
    [self.glView setSyClient:_syClient];
    
    // If we have a client we do nothing - wait until it outputs a frame
    
    // Otherwise clear the view
    if (_syClient == nil)
    {
        frameWidth = 0;
        frameHeight = 0;
        [self.glView setNeedsDisplay:YES];
        return NO;
    }
    
    return YES;
}


-(void)stop
{
    self.currentServerName = nil;
    [_syClient stop];
    _syClient = nil;
}


- (BOOL) startRouter
{
    CGLContextObj context = [[self.glView openGLContext] CGLContextObj];
    _syRouter = [[SyphonServer alloc] initWithName:@"AMSyphonRouter" context:context options:nil];
    self.routing= YES;
    
    return YES;
}


- (void) stopRouter
{
    self.routing= NO;
    [_syRouter stop];
    _syRouter = nil;
}

@end
