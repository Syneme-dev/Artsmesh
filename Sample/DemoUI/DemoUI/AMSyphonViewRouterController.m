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
#import "AMSyphonCamera.h"

@interface AMSyphonViewRouterController ()
@property (weak) IBOutlet AMSyphonView *glView;
@end

@implementation AMSyphonViewRouterController
{
    SyphonClient*   _syClient;
    SyphonServer*   _syRouter;
    
    NSDictionary*   _syCurrentServer;
    
    NSMutableDictionary*  _syServers;
    NSMutableDictionary* _processCounter;
    
    NSTimeInterval fpsStart;
    NSUInteger fpsCount;
    NSUInteger FPS;
    NSUInteger frameWidth;
    NSUInteger frameHeight;
}

-(NSDictionary*) currentServer
{
    return _syCurrentServer;
}

- (void)viewDidLoad {
//    [super viewDidLoad];
    // Do view setup here.
    
    AMSyphonView *subView = [[AMSyphonView alloc] initWithFrame:NSMakeRect(0, 0, 300, 300)];
    self.glView = subView;
    [self.view addSubview:subView];
    
    [subView setTranslatesAutoresizingMaskIntoConstraints:NO];
    NSView *content = subView;
    NSDictionary *views = NSDictionaryOfVariableBindings(content);
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[content]-0-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    [self.view addConstraints:
     [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[content]-0-|"
                                             options:0
                                             metrics:nil
                                               views:views]];
    
    
    [self updateServerList];
    
    self.glView.drawTriangle = NO;
}

-(NSDictionary*)syphonServerDisctriptByName:(NSString*)name
{
    return [_syServers objectForKey:name];
}

-(void)updateServerList
{
    [self syphonServerNames];
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
        
        if([appName isEqualToString:@"Artsmesh"] &&
           ![name isEqualToString:faceTimeCamera])
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
    
    _syCurrentServer = serverDescript;
    
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
            
            self.glView.image = frame;
            
            //routering
            if(self.routing){
                [_syRouter publishFrameTexture:frame.textureName
                                textureTarget:GL_TEXTURE_RECTANGLE_EXT
                                  imageRegion:NSMakeRect(0, 0, frame.textureSize.width, frame.textureSize.height)
                            textureDimensions:frame.textureSize
                                      flipped:NO];
                
            }
            // ...then mark our view as needing display, it will get the frame when it's ready to draw
            
            [self.glView drawRect:self.glView.bounds];
            //[self.glView setNeedsDisplay:YES];
        }];
    }];
    
    
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
