//
//  GLView.h
//  TCPSyphonSDK
//
//  Created by Nozomu MIURA on 2015/05/28.
//
//

#import <Cocoa/Cocoa.h>
#import "TL_TCPSyphonSDK/TL_TCPSyphonSDK.h"

@interface GLView : NSOpenGLView {
    BOOL                needsReshape;
    
    TL_TCPSyphonSDK*    m_TCPSyphonSDK;
}

-(void)setup;
-(void)draw;

-(TL_TCPSyphonSDK*)GetTCPSyphonSDK;

@end
