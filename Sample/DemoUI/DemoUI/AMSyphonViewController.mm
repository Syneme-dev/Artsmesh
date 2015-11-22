//
//  AMSyphonViewController.m
//  SyphonDemo
//
//  Created by WhiskyZed on 11/16/14.
//  Copyright (c) 2014 WhiskyZed. All rights reserved.
//
#import <OpenGL/CGLMacro.h>
#import "AMSyphonViewController.h"
#import "AMTcpSyphonView.h"
#import "AMSyphonCamera.h"
#import "AMSyphonManager.h"

CVReturn displayLinkCallback(CVDisplayLinkRef displayLink,
                             const CVTimeStamp *inNow,
                             const CVTimeStamp *inOutputTime,
                             CVOptionFlags flagsIn,
                             CVOptionFlags *flagsOut,
                             void *displayLinkContext);

NSString* kNonServer = @"    --    ";

@interface AMSyphonViewController ()
@property (weak) IBOutlet AMTcpSyphonView *glView;
@property (weak) IBOutlet NSPopUpButton *serverNamePopUpButton;

@end

@implementation AMSyphonViewController
{
    NSDictionary*           _curServer;
    NSMutableDictionary*    _syServers;
    SyphonClient*           _syClient;
    NSMutableDictionary*    _processCounter;
    
    NSString *              _currSelection;
    
    NSTimeInterval fpsStart;
    NSUInteger fpsCount;
    NSUInteger FPS;
    NSUInteger frameWidth;
    NSUInteger frameHeight;
    
//    CVDisplayLinkRef	displayLink;
    NSOpenGLContext*    sharedContext;
}

- (void)viewDidLoad {
    // [super viewDidLoad];
    // Do view setup here
    
    AMTcpSyphonView *subView = [[AMTcpSyphonView alloc] initWithFrame:NSMakeRect(0, 0, 300, 300)];
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
    self.glView.drawTriangle = YES;

    //Setup for NSNotification
    displayLink = NULL;
    sharedContext = [[NSOpenGLContext alloc]
                     initWithFormat:[self createGLPixelFormat] shareContext:nil];
    
    
    NSNotificationCenter*	nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(updateServerList) name:TL_TCPSyphonSDK_ChangeTCPSyphonServerListNotification object:nil];
    
    NSOpenGLContext		*newCtx = [[NSOpenGLContext alloc] initWithFormat:[self createGLPixelFormat] shareContext:sharedContext] ;
    [_glView setOpenGLContext:newCtx];
    [newCtx setView:_glView];
    [_glView setup];
    [_glView reshape];
    

    
    CVReturn				err = kCVReturnSuccess;
    CGOpenGLDisplayMask		totalDisplayMask = 0;
    GLint					virtualScreen = 0;
    GLint					displayMask = 0;
    NSOpenGLPixelFormat		*format = [self createGLPixelFormat];
    
    for (virtualScreen=0; virtualScreen<[format numberOfVirtualScreens]; ++virtualScreen)	{
        [format getValues:&displayMask forAttribute:NSOpenGLPFAScreenMask forVirtualScreen:virtualScreen];
        totalDisplayMask |= displayMask;
    }
    err = CVDisplayLinkCreateWithOpenGLDisplayMask(totalDisplayMask, &displayLink);
    if (err)	{
        NSLog(@"\t\terr %d creating display link in %s",err,__func__);
        displayLink = NULL;
    }
    else{
        CVDisplayLinkSetOutputCallback(displayLink, displayLinkCallback, (__bridge void *)self);
        CVDisplayLinkStart(displayLink);
    }

}

- (NSOpenGLPixelFormat *) createGLPixelFormat	{
    GLuint				glDisplayMaskForAllScreens = 0;
    CGDirectDisplayID	displays[10];
    CGDisplayCount		count = 0;
    if (CGGetActiveDisplayList(10,displays,&count)==kCGErrorSuccess)	{
        for (int i=0; i<count; ++i)
            glDisplayMaskForAllScreens |= CGDisplayIDToOpenGLDisplayMask(displays[i]);
    }
    
    NSOpenGLPixelFormatAttribute	attrs[] = {
        NSOpenGLPFAAccelerated,
        NSOpenGLPFAScreenMask,glDisplayMaskForAllScreens,
        NSOpenGLPFANoRecovery,
        NSOpenGLPFAAllowOfflineRenderers,
        0};
    return [[NSOpenGLPixelFormat alloc] initWithAttributes:attrs];
}

//For tcpSyphon
-(NSArray*) tcpSyphonServerList
{
    NSMutableArray* serverNames = [[NSMutableArray alloc] init];
    TL_TCPSyphonSDK*    sdk = [_glView GetTCPSyphonSDK];
    

    NSArray*    servers = [sdk GetTCPSyphonServerInformation];
    for (NSDictionary* info in servers)
    {
        [serverNames addObject:[info objectForKey:@"Name"]];
    }
    
    return serverNames;
}


-(void)updateServerList
{
    [self.serverNamePopUpButton removeAllItems];
    [self.serverNamePopUpButton addItemWithTitle:kNonServer];
    
    [self.serverNamePopUpButton addItemsWithTitles:[self syphonServerNames]];
    
    [self.serverNamePopUpButton addItemsWithTitles:[self tcpSyphonServerList]];
    
    [self.serverNamePopUpButton selectItemWithTitle: _currentServerName];
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
        
        if ([AMSyphonName isSyphonRouter:name]) {
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

- (void) renderCallback	{
    [_glView draw];
}


- (IBAction)serverSelected:(NSPopUpButton *)sender
{
    [self stop ];
    _currSelection = sender.selectedItem.title;
                      
    if ([sender.selectedItem.title isEqualToString:kNonServer]) {
        return;
    }
    
    ///11---------------Here for tcp syphon
    NSString*   selectedname = [sender titleOfSelectedItem];
    if ([selectedname rangeOfString:@"TCPSyphon"].location != NSNotFound) {
        TL_TCPSyphonSDK*    sdk = [_glView GetTCPSyphonSDK];
        [sdk ConnectToTCPSyphonServerByName:selectedname];
        
        return;
    }
    
    /////11-------
    
    
    
    
    
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
            
            [self.glView drawRect:self.glView.bounds];
        
            
        
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

CVReturn displayLinkCallback(CVDisplayLinkRef displayLink,
                             const CVTimeStamp *inNow,
                             const CVTimeStamp *inOutputTime,
                             CVOptionFlags flagsIn,
                             CVOptionFlags *flagsOut,
                             void *displayLinkContext)
{
    // NSAutoreleasePool		*pool =[[NSAutoreleasePool alloc] init];
    [(__bridge AMSyphonViewController*)displayLinkContext renderCallback];
    //[pool release];
    return kCVReturnSuccess;
}

