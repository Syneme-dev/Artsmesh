//
//  AMTcpSyphonView.h
//  Artsmesh
//
//  Created by whiskyzed on 11/13/15.
//  Copyright © 2015 Artsmesh. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import <OpenGL/OpenGL.h>
#import <Syphon/Syphon.h>
#import "TL_TCPSyphonSDK/TL_TCPSyphonSDK.h"

@interface AMTcpSyphonView : NSOpenGLView
{
    BOOL                needsReshape;
    
    TL_TCPSyphonSDK*    m_TCPSyphonSDK;
}

-(void)setup;
-(void)draw;

-(TL_TCPSyphonSDK*)GetTCPSyphonSDK;

@property SyphonImage*      image;
@property Boolean           drawTriangle;
@end
