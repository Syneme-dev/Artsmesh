//  AMAVFSyphonSender.h
//  AMAVFSyphonSender
//  Created by WhiskyZed on 2015.09.24


#import <Foundation/Foundation.h>
#import <OpenGL/OpenGL.h>
#import <OpenGL/gl.h>
#import <Syphon/Syphon.h>
#import "AVFWrapper.h"


@interface AMSyphonSender : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    NSOpenGLContext*    glContext;
    CGLContextObj       cgl_ctx;
    SyphonServer*       server;
    
    NSString                            *_currentDevice;
	
    AVCaptureSession					*mCaptureSession;
    AVCaptureDeviceInput				*mCaptureDeviceInput;
    
    GLuint texture;
    NSInteger curWidth;
    NSInteger curHeight;
    
    BOOL running;
}

//when set to YES the video device called "deviceName" will be captured to syphon
@property (nonatomic) BOOL enabled;
//sets the video device name to be used for capturing
@property (nonatomic, retain) NSString *deviceName;

@end
