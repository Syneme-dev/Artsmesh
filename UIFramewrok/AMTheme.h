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
#define UI_Image_Panel_Btn_Manual @"SideBar_Manual"
#define UI_Image_Panel_Btn_Manual_Alt @"SideBar_Manual_h"
#define UI_Image_Panel_Btn_User @"SideBar_user"
#define UI_Image_Panel_Btn_User_Alt @"SideBar_user_h"
#define UI_Image_Panel_Btn_Group @"SideBar_group"
#define UI_Image_Panel_Btn_Group_Alt @"SideBar_group_h"
#define UI_Image_Panel_Btn_Chat @"SideBar_chat"
#define UI_Image_Panel_Btn_Chat_Alt @"SideBar_chat_h"
#define UI_Image_Panel_Btn_Social @"SideBar_social"
#define UI_Image_Panel_Btn_Social_Alt @"SideBar_social_h"
#define UI_Image_Panel_Btn_Map @"SideBar_mapView"
#define UI_Image_Panel_Btn_Map_Alt @"SideBar_mapView_h"
#define UI_Image_Panel_Btn_Route @"SideBar_route"
#define UI_Image_Panel_Btn_Route_Alt @"SideBar_route_h"
#define UI_Image_Panel_Btn_Video @"SideBar_video"
#define UI_Image_Panel_Btn_Video_Alt @"SideBar_video_h"
#define UI_Image_Panel_Btn_Music @"SideBar_musicScore"
#define UI_Image_Panel_Btn_Music_Alt @"SideBar_musicScore_h"
#define UI_Image_Panel_Btn_Clock @"SideBar_clock"
#define UI_Image_Panel_Btn_Clock_Alt @"SideBar_clock_h"
#define UI_Image_Panel_Btn_OSC @"SideBar_osc"
#define UI_Image_Panel_Btn_OSC_Alt @"SideBar_osc_h"
#define UI_Image_Panel_Btn_Terminal @"SideBar_terminal"
#define UI_Image_Panel_Btn_Terminal_Alt @"SideBar_terminal_h"
#define UI_Image_Panel_Btn_Settings @"SideBar_setting"
#define UI_Image_Panel_Btn_Settings_Alt @"SideBar_setting_h"
#define UI_Image_Panel_Btn_Broadcast @"menu_broadcast_icon"
#define UI_Image_Panel_Btn_Broadcast_Alt @"menu_broadcast_icon_h"

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
