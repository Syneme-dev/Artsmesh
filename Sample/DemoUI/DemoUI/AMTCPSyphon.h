//
//  AppDelegate.h
//  SampleClient
//
//  Created by Nozomu MIURA on 2015/05/28.
//
//

#import <Cocoa/Cocoa.h>
#import "GLView.h"

@interface AMTCPSyphon : NSObject
{
    CVDisplayLinkRef			displayLink;
    NSOpenGLContext				*sharedContext;
    
    IBOutlet NSWindow			*window;
    IBOutlet GLView				*glView;
    
    IBOutlet NSPopUpButton *m_TCPSyphonServerPopupButton;
}

- (NSOpenGLPixelFormat *) createGLPixelFormat;

- (IBAction)ChangedTCPSyphonServerPopupButton:(id)sender;

@end

