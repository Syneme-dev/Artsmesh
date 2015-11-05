//
//  TL_TCPSyphonSDK.h
//  TL_TCPSyphonSDK
//
//  Created by Nozomu MIURA on 2015/05/28.
//  Copyright (c) 2015 TECHLIFE SG Pte.Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>

//! Project version number for TL_TCPSyphonSDK.
FOUNDATION_EXPORT double TL_TCPSyphonSDKVersionNumber;

//! Project version string for TL_TCPSyphonSDK.
FOUNDATION_EXPORT const unsigned char TL_TCPSyphonSDKVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <TL_TCPSyphonSDK/PublicHeader.h>


namespace TCPUDPSyphon {
    
    enum EncodeType {
        EncodeType_JPEG,
        EncodeType_JPEGGLITCH,
        EncodeType_RAW,
        EncodeType_PNG,
        EncodeType_TURBOJPEG
    };
};

#define TL_TCPSyphonSDK_ChangeTCPSyphonServerListNotification   @"TL_TCPSyphonSDK_ChangeTCPSyphonServerListNotification"

@interface TL_TCPSyphonSDK : NSObject

//-=-= SERVER SECTION -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//Control server
-(void)StartServer:(NSString*)appname;
-(void)StopServer;

//assign texture
//supports GL_RGBA and GL_UNSIGNED_BYTE only.
-(void)SetSendImageWithGLContext:(CGLContextObj)cgl_ctx Target:(GLenum)target Texture:(GLuint)texture Area:(NSRect)area;

//set parameters
//Default encode type: TCPUDPSyphon::EncodeType_TURBOJPEG
-(void)SetEncodeType:(TCPUDPSyphon::EncodeType)encodetype;
//Default encode quality: 0.5 ( bad:0.0, good:1.0 )
-(void)SetEncodeQuality:(float)quality;

//get information
-(NSDictionary*)GetSyphonServerInformation;
-(NSArray*)GetTCPSyphonClientInformation;
-(unsigned int)GetSendingDataSize;
//-=-= SERVER SECTION -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

//-=-= CLIENT SECTION -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=
//Control client
-(void)StartClient:(CGLContextObj)cgl_ctx;
-(void)StopClient:(CGLContextObj)cgl_ctx;

//Connect,Disconnect
-(void)ConnectToTCPSyphonServerAtIndex:(int)index;
-(int)ConnectToTCPSyphonServerByName:(NSString*)name;
-(void)DisconnectToTCPSyphonServer;
-(NSString*)GetConnectedTCPSyphonServerName;

-(void)ClientIdle:(CGLContextObj)cgl_ctx;
-(int)GetReceiveTextureFromTCPSyphonServer:(GLuint*)texture Resolution:(NSSize*)texturesize TextureTarget:(GLenum*)texturetarget;

-(NSArray*)GetTCPSyphonServerInformation;
//-=-= CLIENT SECTION -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=

@end

