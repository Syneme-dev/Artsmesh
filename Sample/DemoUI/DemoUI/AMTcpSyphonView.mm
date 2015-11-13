//
//  AMTcpSyphonView.m
//  Artsmesh
//
//  Created by whiskyzed on 11/13/15.
//  Copyright © 2015 Artsmesh. All rights reserved.
//

#import "AMTcpSyphonView.h"
#import "TL_TCPSyphonSDK/TL_TCPSyphonSDK.h"

@implementation AMTcpSyphonView
{
    BOOL canDraw;
}

@synthesize drawTriangle;
-(void) awakeFromNib
{
    const GLint on = 1;
    [[self openGLContext] setValues:&on forParameter:NSOpenGLCPSwapInterval];
    drawTriangle = YES;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

-(void) viewDidMoveToWindow
{
    [super viewDidMoveToWindow];
    if ([self window] == nil){
        canDraw = NO;
        [[self openGLContext] clearDrawable];
    }else{
        canDraw  =YES;
    }
    
}

-(BOOL)canDraw
{
    return canDraw;
}


- (void)lockFocus
{
    NSOpenGLContext* context = [self openGLContext];
    
    [super lockFocus];
    if ([context view] != self) {
        [context setView:self];
    }
    [context makeCurrentContext];
}



- (void)drawRect:(NSRect)dirtyRect
{
    //       [[NSColor redColor] set];
    //        [NSBezierPath fillRect:self.bounds];
    //       return;
    if (!canDraw) {
        return;
    }
    
    [self lockFocus];
    
    NSRect frame = self.frame;
    glClearColor(0.0, 0.0, 0.0, 0.0);
    glClear(GL_COLOR_BUFFER_BIT);
    
    // Setup OpenGL states
    glViewport(0, 0, frame.size.width, frame.size.height);
    glMatrixMode(GL_PROJECTION);
    glPushMatrix();
    glLoadIdentity();
    glOrtho(0.0, frame.size.width, 0.0, frame.size.height, -1, 1);
    
    glMatrixMode(GL_MODELVIEW);
    glPushMatrix();
    glLoadIdentity();
    
    // Get a new frame from the client
    SyphonImage *image = self.image;
    if(image)
    {
        glEnable(GL_TEXTURE_RECTANGLE_ARB);
        glBindTexture(GL_TEXTURE_RECTANGLE_ARB, [image textureName]);
        // do a nearest linear interp.
        glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_RECTANGLE_ARB, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        
        glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
        
        glColor4f(1.0, 1.0, 1.0, 1.0);
        
        // why do we need it ?
        glDisable(GL_BLEND);
        
        NSSize imageSize = [image textureSize];
        NSSize scaled;
        float wr = imageSize.width / frame.size.width;
        float hr = imageSize.height / frame.size.height;
        float ratio;
        ratio = (hr < wr ? wr : hr);
        scaled = NSMakeSize((imageSize.width / ratio), (imageSize.height / ratio));
        
        float imageWidth  = imageSize.width;
        float imageHeight = imageSize.height;
        
        GLfloat tex_coords[] =
        {
            0.0,	0.0,
            imageWidth,	0.0,
            imageWidth,	imageHeight,
            0.0,	imageHeight
        };
        
        
        float halfw = scaled.width * 0.5;
        float halfh = scaled.height * 0.5;
        
        GLfloat verts[] =
        {
            -halfw, -halfh,
            halfw, -halfh,
            halfw, halfh,
            -halfw, halfh
        };
        
        glTranslated(frame.size.width * 0.5, frame.size.height * 0.5, 0.0);
        
        glEnableClientState( GL_TEXTURE_COORD_ARRAY );
        glTexCoordPointer(2, GL_FLOAT, 0, tex_coords );
        glEnableClientState(GL_VERTEX_ARRAY);
        glVertexPointer(2, GL_FLOAT, 0, verts );
        glDrawArrays( GL_TRIANGLE_FAN, 0, 4 );
        glDisableClientState( GL_TEXTURE_COORD_ARRAY );
        glDisableClientState(GL_VERTEX_ARRAY);
        
        glBindTexture(GL_TEXTURE_RECTANGLE_ARB, 0);
        
        // We are responsible for releasing the frame
        //       [image release];
    }
    
    
    
    // Restore OpenGL states
    glMatrixMode(GL_MODELVIEW);
    glPopMatrix();
    
    glMatrixMode(GL_PROJECTION);
    glPopMatrix();
    
    if(!image && drawTriangle){
        glColor3f(61/255.0, 75/255.0, 93/255.0);
        glBegin(GL_TRIANGLES);
        {
            glVertex3f(  1,  -0.8, 0.0);
            glVertex3f(  1,     -1, 0.0);
            glVertex3f(  0.8,     -1 ,0.0);
        }
        glEnd();
    }
    
    
    glFlush();
    
    [self unlockFocus];
    //[[self openGLContext] flushBuffer];
    
}


-(void)setup
{
    CGLContextObj cgl_ctx = [[self openGLContext] CGLContextObj];
    
    m_TCPSyphonSDK = [[TL_TCPSyphonSDK alloc] init];
    [m_TCPSyphonSDK StartClient:cgl_ctx];
}


- (void)reshape
{
    needsReshape = YES;
}


- (void)update
{
    CGLLockContext([[self openGLContext] CGLContextObj]);
    [super update];
    CGLUnlockContext([[self openGLContext] CGLContextObj]);
}


-(void)draw
{
    GLuint  texture;
    NSSize  texturesize;
    GLenum  texturetarget;
    CGLContextObj cgl_ctx = [[self openGLContext] CGLContextObj];
    
    CGLLockContext(cgl_ctx);
    
    NSRect bounds = self.bounds;
    
    if (needsReshape)
    {
        glDisable(GL_DEPTH_TEST);
        glDisable(GL_BLEND);
        glHint(GL_CLIP_VOLUME_CLIPPING_HINT_EXT, GL_FASTEST);
        
        glMatrixMode(GL_TEXTURE);
        glLoadIdentity();
        glMatrixMode(GL_MODELVIEW);
        glLoadIdentity();
        glMatrixMode(GL_PROJECTION);
        glLoadIdentity();
        glViewport(0, 0, (GLsizei) bounds.size.width, (GLsizei) bounds.size.height);
        glOrtho(bounds.origin.x, bounds.origin.x+bounds.size.width, bounds.origin.y, bounds.origin.y+bounds.size.height, -1.0, 1.0);
        
        glTexEnvi(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_REPLACE);
        
        needsReshape = NO;
    }
    
    glClearColor(0.0,0.0,0.0,0.0);
    glClear( GL_COLOR_BUFFER_BIT );
    
    [m_TCPSyphonSDK ClientIdle:cgl_ctx];
    
    if ( ![m_TCPSyphonSDK GetReceiveTextureFromTCPSyphonServer:&texture Resolution:&texturesize TextureTarget:&texturetarget] )
    {
        glColor4f( 1,1,1, 1.0f );
        
        glActiveTexture( GL_TEXTURE0 );
        glEnable( texturetarget );
        glBindTexture( texturetarget, texture );
        
        glBegin( GL_QUADS );
        glTexCoord2f( 0, 0 );
        glVertex2f( 0, 0 );
        
        glTexCoord2f( texturesize.width, 0 );
        glVertex2f( bounds.size.width, 0 );
        
        glTexCoord2f( texturesize.width, texturesize.height );
        glVertex2f( bounds.size.width, bounds.size.height );
        
        glTexCoord2f( 0, texturesize.height );
        glVertex2f( 0, bounds.size.height );
        glEnd();
        
        glDisable( GL_TEXTURE_RECTANGLE_EXT );
        glDisable( GL_BLEND );
    }
    
    glFlush();
    
    CGLUnlockContext(cgl_ctx);
}


-(TL_TCPSyphonSDK*)GetTCPSyphonSDK
{
    return m_TCPSyphonSDK;
}


@end
