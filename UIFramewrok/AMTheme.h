//
//  AMThemes.h
//  Artsmesh
//
//  Created by Brad Phillips on 9/5/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>

// Default Dark theme color definitions
#define UI_Color_Gray [NSColor colorWithCalibratedRed:0.152 green:0.152 blue:0.152 alpha:1]
#define UI_Color_Light_Grey  [NSColor colorWithCalibratedRed:(168)/255.0f green:(168)/255.0f blue:(168)/255.0f alpha:1.0f]
#define UI_Color_Grey_Primary [NSColor colorWithCalibratedRed:(51)/255.0f green:(51)/255.0f blue:(51)/255.0f alpha:1.0f]
#define UI_Color_Disabled  [NSColor colorWithCalibratedRed:(84)/255.0f green:(84)/255.0f blue:(84)/255.0f alpha:1.0f]
#define UI_Color_Blue [NSColor colorWithCalibratedRed:(46)/255.0f green:(58)/255.0f blue:(75)/255.0f alpha:1.0f]
#define UI_Color_Red [NSColor colorWithCalibratedRed:(255)/255.0f green:(0)/255.0f blue:(0)/255.0f alpha:1.0f]
#define UI_Color_Yellow [NSColor colorWithCalibratedRed:(255)/255.0f green:(255)/255.0f blue:(0)/255.0f alpha:1.0f]
#define UI_Color_Green [NSColor colorWithCalibratedRed:(0)/255.0f green:(255)/255.0f blue:(0)/255.0f alpha:1.0f]

#define Preference_Key_Color_Background @"Preference_Key_Color_Background"

// Default UI Panel Image Names
#define UI_Image_Panel_Btn_Manual @"Sidebar_Manual"
#define UI_Image_Panel_Btn_Manual_Alt @"sidebar_Manual_h"
#define UI_Image_Panel_Btn_User @"Sidebar_user"
#define UI_Image_Panel_Btn_User_Alt @"Sidebar_user_h"
#define UI_Image_Panel_Btn_Group @"Sidebar_group"
#define UI_Image_Panel_Btn_Group_Alt @"Sidebar_group_h"
#define UI_Image_Panel_Btn_Chat @"Sidebar_chat"
#define UI_Image_Panel_Btn_Chat_Alt @"Sidebar_chat_h"
#define UI_Image_Panel_Btn_Social @"Sidebar_social"
#define UI_Image_Panel_Btn_Social_Alt @"Sidebar_social_h"
#define UI_Image_Panel_Btn_User @"Sidebar_user"
#define UI_Image_Panel_Btn_User_Alt @"Sidebar_user_h"
#define UI_Image_Panel_Btn_Map @"Sidebar_mapView"
#define UI_Image_Panel_Btn_Map_Alt @"Sidebar_mapView_h"
#define UI_Image_Panel_Btn_Route @"Sidebar_route"
#define UI_Image_Panel_Btn_Route_Alt @"Sidebar_route_h"
#define UI_Image_Panel_Btn_Video @"Sidebar_video"
#define UI_Image_Panel_Btn_Video_Alt @"Sidebar_video_h"
#define UI_Image_Panel_Btn_Music @"Sidebar_musicScore"
#define UI_Image_Panel_Btn_Music_Alt @"Sidebar_musicScore_h"
#define UI_Image_Panel_Btn_Clock @"Sidebar_clock"
#define UI_Image_Panel_Btn_Clock_Alt @"Sidebar_clock_h"
#define UI_Image_Panel_Btn_OSC @"Sidebar_osc"
#define UI_Image_Panel_Btn_OSC_Alt @"Sidebar_osc_h"
#define UI_Image_Panel_Btn_Terminal @"Sidebar_terminal"
#define UI_Image_Panel_Btn_Terminal_Alt @"Sidebar_terminal_h"
#define UI_Image_Panel_Btn_Settings @"Sidebar_setting"
#define UI_Image_Panel_Btn_Settings_Alt @"Sidebar_setting_h"
#define UI_Image_Panel_Btn_Broadcast @"Sidebar_broadcast"
#define UI_Image_Panel_Btn_Broadcast_Alt @"Sidebar_broadcast_h"

@interface AMTheme : NSObject

@property (strong) NSDictionary *themeFonts;
@property (strong) NSDictionary *themeColors;

// Color Properties
@property (strong) NSColor *colorAlert;
@property (strong) NSColor *colorError;
@property (strong) NSColor *colorSuccess;

@property (strong) NSColor *colorText;
@property (strong) NSColor *colorTextDisabled;
@property (strong) NSColor *colorTextAlert;
@property (strong) NSColor *colorTextError;
@property (strong) NSColor *colorTextSuccess;

@property (strong) NSColor *colorBorder;
@property (strong) NSColor *colorBorderAlert;
@property (strong) NSColor *colorBorderError;
@property (strong) NSColor *colorBorderSuccess;

@property (strong) NSColor *colorBackground;
@property (strong) NSColor *colorBackgroundAlert;
@property (strong) NSColor *colorBackgroundError;
@property (strong) NSColor *colorBackgroundSuccess;
@property (strong) NSColor *colorBackgroundHover;


// Font Properties
@property (strong) NSFont *fontStandard;
@property (strong) NSFont *fontStandardItalic;

@property (strong) NSFont *fontHeader;
@property (strong) NSFont *fontHeaderItalic;

// Images
@property (strong) NSImage *imagePanelBtnManual;
@property (strong) NSImage *imagePanelBtnManualAlt;
@property (strong) NSImage *imagePanelBtnUser;
@property (strong) NSImage *imagePanelBtnUserAlt;
@property (strong) NSImage *imagePanelBtnGroup;
@property (strong) NSImage *imagePanelBtnGroupAlt;
@property (strong) NSImage *imagePanelBtnChat;
@property (strong) NSImage *imagePanelBtnChatAlt;
@property (strong) NSImage *imagePanelBtnSocial;
@property (strong) NSImage *imagePanelBtnSocialAlt;
@property (strong) NSImage *imagePanelBtnMap;
@property (strong) NSImage *imagePanelBtnMapAlt;
@property (strong) NSImage *imagePanelBtnRoute;
@property (strong) NSImage *imagePanelBtnRouteAlt;
@property (strong) NSImage *imagePanelBtnVideo;
@property (strong) NSImage *imagePanelBtnVideoAlt;
@property (strong) NSImage *imagePanelBtnMusic;
@property (strong) NSImage *imagePanelBtnMusicAlt;
@property (strong) NSImage *imagePanelBtnClock;
@property (strong) NSImage *imagePanelBtnClockAlt;
@property (strong) NSImage *imagePanelBtnOSC;
@property (strong) NSImage *imagePanelBtnOSCAlt;
@property (strong) NSImage *imagePanelBtnTerminal;
@property (strong) NSImage *imagePanelBtnTerminalAlt;
@property (strong) NSImage *imagePanelBtnSettings;
@property (strong) NSImage *imagePanelBtnSettingsAlt;
@property (strong) NSImage *imagePanelBtnBroadcast;
@property (strong) NSImage *imagePanelBtnBroadcastAlt;

// Methods
+ (AMTheme *) sharedInstance;
-(void) setTheme: (NSString *)themeName;

@end
