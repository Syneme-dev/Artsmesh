//
//  AMSyphonView.m
//  SyphonDemo
//
//  Created by WhiskyZed on 11/15/14.
//  Copyright (c) 2014 WhiskyZed. All rights reserved.
//

#import "AMSyphonView.h"

@implementation AMSyphonView

-(void) awakeFromNib
{
    const GLint on = 1;
    [[self openGLContext] setValues:&on forParameter:NSOpenGLCPSwapInterval];
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

//-(void) viewDidMoveToWindow
//{
//    [super viewDidMoveToWindow];
//    if ([self window] == nil)
//        [[self openGLContext] clearDrawable];
//}

static void drawAnObject ()
{
    glColor3f(1.0f, 0.85f, 0.35f);
    glBegin(GL_TRIANGLES);
    {
        glVertex3f(  0.0,  0.6, 0.0);
        glVertex3f( -0.2, -0.3, 0.0);
        glVertex3f(  0.2, -0.3 ,0.0);
    }
    glEnd();
}

-(BOOL)canDraw
{
    return YES;
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
        
        GLfloat tex_coords[] =
        {
            0.0,	0.0,
            imageSize.width,	0.0,
            imageSize.width,	imageSize.height,
            0.0,	imageSize.height
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
    
    glFlush();
    
    [self unlockFocus];
    //[[self openGLContext] flushBuffer];
    
}

@end
