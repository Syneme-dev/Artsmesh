//
//  AMThemes.m
//  Artsmesh
//
//  Created by Brad Phillips on 9/5/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AMTheme.h"

@implementation AMTheme

+ (AMTheme *) sharedInstance
{
    static AMTheme* sharedTheme = nil;
    @synchronized(self){
        if (sharedTheme == nil){
            sharedTheme = [[self alloc] privateInit];
        }
    }
    return sharedTheme;
}

- (instancetype)privateInit
{
    NSString *curTheme = [[NSUserDefaults standardUserDefaults] stringForKey:@"Preference_Key_Active_Theme"];
        
    self.themeColors = [[NSDictionary alloc] initWithObjectsAndKeys:
                            UI_Color_Gray, @"background",
                            UI_Color_Light_Grey, @"textDefault",
                            UI_Color_Yellow, @"alert",
                            UI_Color_Red, @"warning",
                            UI_Color_Blue, @"hoverDefault",
                            nil];
        
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    self.themeFonts = [[NSDictionary alloc] initWithObjectsAndKeys:
                      [fontManager fontWithFamily:@"FoundryMonoline" traits:NSUnitalicFontMask weight:8 size:12.0], @"header",
                      [fontManager fontWithFamily:@"FoundryMonoline" traits:NSItalicFontMask weight:8 size:12.0], @"header-italic",
                      [fontManager fontWithFamily:@"FoundryMonoline" traits:NSUnitalicFontMask weight:8 size:10.0], @"standard",
                      [fontManager fontWithFamily:@"FoundryMonoline" traits:NSItalicFontMask weight:8 size:10.0], @"standard-italic",
                      nil];
        
    // Set default theme colors
    self.colorAlert = UI_Color_Yellow;
    self.colorError = UI_Color_Red;
    self.colorSuccess = UI_Color_Green;
        
    self.colorBackground = UI_Color_Gray;
    self.colorBackgroundAlert = UI_Color_Red;
    self.colorBackgroundError = UI_Color_Yellow;
    self.colorBackgroundSuccess = UI_Color_Green;
    self.colorBackgroundHover = UI_Color_Blue;
        
    self.colorBorder = UI_Color_Light_Grey;
    self.colorBorderAlert = UI_Color_Red;
    self.colorBorderError = UI_Color_Yellow;
    self.colorBorderSuccess = UI_Color_Green;
        
    self.colorText = UI_Color_Light_Grey;
    self.colorTextDisabled = UI_Color_Disabled;
    self.colorTextAlert = UI_Color_Red;
    self.colorTextError = UI_Color_Yellow;
    self.colorTextSuccess = UI_Color_Green;
    
    // Set default theme fonts
    self.fontHeader = [fontManager fontWithFamily:@"FoundryMonoline" traits:NSItalicFontMask weight:8 size:12.0];
    self.fontHeaderItalic = [fontManager fontWithFamily:@"FoundryMonoline" traits:NSItalicFontMask weight:8 size:12.0];
    self.fontStandard = [fontManager fontWithFamily:@"FoundryMonoline" traits:NSUnitalicFontMask weight:8 size:10.0];
    self.fontStandardItalic = [fontManager fontWithFamily:@"FoundryMonoline" traits:NSItalicFontMask weight:8 size:10.0];
    
    // set default theme images
    self.imagePanelBtnManual = [NSImage imageNamed:UI_Image_Panel_Btn_Manual];
    self.imagePanelBtnManualAlt = [NSImage imageNamed:UI_Image_Panel_Btn_Manual_Alt];
    self.imagePanelBtnUser = [NSImage imageNamed: UI_Image_Panel_Btn_User];
    self.imagePanelBtnUserAlt = [NSImage imageNamed:UI_Image_Panel_Btn_User_Alt];
    self.imagePanelBtnGroup = [NSImage imageNamed: UI_Image_Panel_Btn_Group];
    self.imagePanelBtnGroupAlt = [NSImage imageNamed:UI_Image_Panel_Btn_Group_Alt];
    self.imagePanelBtnChat = [NSImage imageNamed: UI_Image_Panel_Btn_Chat];
    self.imagePanelBtnChatAlt = [NSImage imageNamed:UI_Image_Panel_Btn_Chat_Alt];
    self.imagePanelBtnSocial = [NSImage imageNamed: UI_Image_Panel_Btn_Social];
    self.imagePanelBtnSocialAlt = [NSImage imageNamed:UI_Image_Panel_Btn_Social_Alt];
    self.imagePanelBtnMap = [NSImage imageNamed: UI_Image_Panel_Btn_Map];
    self.imagePanelBtnMapAlt = [NSImage imageNamed:UI_Image_Panel_Btn_Map_Alt];
    self.imagePanelBtnRoute = [NSImage imageNamed: UI_Image_Panel_Btn_Route];
    self.imagePanelBtnRouteAlt = [NSImage imageNamed:UI_Image_Panel_Btn_Route_Alt];
    self.imagePanelBtnVideo = [NSImage imageNamed: UI_Image_Panel_Btn_Video];
    self.imagePanelBtnVideoAlt = [NSImage imageNamed:UI_Image_Panel_Btn_Video_Alt];
    self.imagePanelBtnMusic = [NSImage imageNamed: UI_Image_Panel_Btn_Music];
    self.imagePanelBtnMusicAlt = [NSImage imageNamed:UI_Image_Panel_Btn_Music_Alt];
    self.imagePanelBtnClock = [NSImage imageNamed: UI_Image_Panel_Btn_Clock];
    self.imagePanelBtnClockAlt = [NSImage imageNamed:UI_Image_Panel_Btn_Clock_Alt];
    self.imagePanelBtnOSC = [NSImage imageNamed: UI_Image_Panel_Btn_OSC];
    self.imagePanelBtnOSCAlt = [NSImage imageNamed:UI_Image_Panel_Btn_OSC_Alt];
    self.imagePanelBtnTerminal = [NSImage imageNamed: UI_Image_Panel_Btn_Terminal];
    self.imagePanelBtnTerminalAlt = [NSImage imageNamed:UI_Image_Panel_Btn_Terminal_Alt];
    self.imagePanelBtnSettings = [NSImage imageNamed: UI_Image_Panel_Btn_Settings];
    self.imagePanelBtnSettingsAlt = [NSImage imageNamed:UI_Image_Panel_Btn_Settings_Alt];
    self.imagePanelBtnBroadcast = [NSImage imageNamed: UI_Image_Panel_Btn_Broadcast];
    self.imagePanelBtnBroadcastAlt = [NSImage imageNamed:UI_Image_Panel_Btn_Broadcast_Alt];
    
    
    if (![curTheme isEqualToString: @"dark"]) {
        [self setTheme:curTheme];
    } else {
        [self setTheme:@"default"];
    }
    
    return [super init];
}

-(void) setTheme: (NSString *)themeName {
    NSColor *newColorAlert;
    NSColor *newColorError;
    NSColor *newColorSuccess;
    
    NSColor *newColorBackground;
    NSColor *newColorBackgroundPrimary;
    NSColor *newColorBackgroundAlert;
    NSColor *newColorBackgroundError;
    NSColor *newColorBackgroundSuccess;
    NSColor *newColorBackgroundHover;
    
    NSColor *newColorBorder;
    NSColor *newColorBorderAlert;
    NSColor *newColorBorderError;
    NSColor *newColorBorderSuccess;
    
    NSColor *newColorText;
    NSColor *newColorTextAlert;
    NSColor *newColorTextError;
    NSColor *newColorTextSuccess;
    
    NSFontManager *fontManager = [NSFontManager sharedFontManager];
    NSFont *newFontHeader;
    NSFont *newFontHeaderItalic;
    NSFont *newFontStandard;
    NSFont *newFontStandardItalic;
    
    NSImage *newImagePanelBtnManual;
    NSImage *newImagePanelBtnManualAlt;
    NSImage *newImagePanelBtnUser;
    NSImage *newImagePanelBtnUserAlt;
    NSImage *newImagePanelBtnGroup;
    NSImage *newImagePanelBtnGroupAlt;
    NSImage *newImagePanelBtnChat;
    NSImage *newImagePanelBtnChatAlt;
    NSImage *newImagePanelBtnSocial;
    NSImage *newImagePanelBtnSocialAlt;
    NSImage *newImagePanelBtnMap;
    NSImage *newImagePanelBtnMapAlt;
    NSImage *newImagePanelBtnRoute;
    NSImage *newImagePanelBtnRouteAlt;
    NSImage *newImagePanelBtnVideo;
    NSImage *newImagePanelBtnVideoAlt;
    NSImage *newImagePanelBtnMusic;
    NSImage *newImagePanelBtnMusicAlt;
    NSImage *newImagePanelBtnClock;
    NSImage *newImagePanelBtnClockAlt;
    NSImage *newImagePanelBtnOSC;
    NSImage *newImagePanelBtnOSCAlt;
    NSImage *newImagePanelBtnTerminal;
    NSImage *newImagePanelBtnTerminalAlt;
    NSImage *newImagePanelBtnSettings;
    NSImage *newImagePanelBtnSettingsAlt;
    NSImage *newImagePanelBtnBroadcast;
    NSImage *newImagePanelBtnBroadcastAlt;
    
    // If no theme matches one called, go with default colors
    newColorAlert = UI_Color_Yellow;
    newColorError = UI_Color_Red;
    newColorSuccess = UI_Color_Green;
    
    newColorBackground = UI_Color_Gray;
    newColorBackgroundAlert = UI_Color_Yellow;
    newColorBackgroundError = UI_Color_Red;
    newColorBackgroundSuccess = UI_Color_Green;
    newColorBackgroundHover = UI_Color_Blue;
    
    newColorBorder = UI_Color_Light_Grey;
    newColorBorderAlert = UI_Color_Red;
    newColorBorderError = UI_Color_Yellow;
    newColorBorderSuccess = UI_Color_Green;
    
    newColorText = UI_Color_Light_Grey;
    newColorTextAlert = UI_Color_Yellow;
    newColorTextError = UI_Color_Red;
    newColorTextSuccess = UI_Color_Green;
    
    
    if ( [themeName isEqualToString:@"light"] ) {
        // Configure variables to match light theme
        newColorBackground = [NSColor colorWithCalibratedRed:(221)/255.0f green:(221)/255.0f blue:(221)/255.0f alpha:1.0f];
        newColorBackgroundHover = [NSColor colorWithCalibratedRed:(60)/255.0f green:(75)/255.0f blue:(95)/255.0f alpha:1.0f];
        
        // Define light theme images
        newImagePanelBtnManual = [NSImage imageNamed:@"Sidebar_Manual_Light_Grey"];
        newImagePanelBtnManualAlt = [NSImage imageNamed:@"Sidebar_Manual_Light_Red"];
        newImagePanelBtnUser = [NSImage imageNamed:@"Sidebar_User_Light_Grey"];
        newImagePanelBtnUserAlt = [NSImage imageNamed:@"Sidebar_User_Light_Red"];
        newImagePanelBtnGroup = [NSImage imageNamed:@"Sidebar_Group_Light_Grey"];
        newImagePanelBtnGroupAlt = [NSImage imageNamed:@"Sidebar_Group_Light_Red"];
        newImagePanelBtnChat = [NSImage imageNamed:@"Sidebar_Chat_Light_Grey"];
        newImagePanelBtnChatAlt = [NSImage imageNamed:@"Sidebar_Chat_Light_Red"];
        newImagePanelBtnSocial = [NSImage imageNamed:@"Sidebar_Social_Light_Grey"];
        newImagePanelBtnSocialAlt = [NSImage imageNamed:@"Sidebar_Social_Light_Red"];
        newImagePanelBtnMap = [NSImage imageNamed:@"Sidebar_mapView_Light_Grey"];
        newImagePanelBtnMapAlt = [NSImage imageNamed:@"Sidebar_mapView_Light_Red"];
        newImagePanelBtnRoute = [NSImage imageNamed:@"Sidebar_Route_Light_Grey"];
        newImagePanelBtnRouteAlt = [NSImage imageNamed:@"Sidebar_Route_Light_Red"];
        newImagePanelBtnVideo = [NSImage imageNamed:@"Sidebar_Video_Light_Grey"];
        newImagePanelBtnVideoAlt = [NSImage imageNamed:@"Sidebar_Video_Light_Red"];
        newImagePanelBtnMusic = [NSImage imageNamed:@"Sidebar_Music_Light_Grey"];
        newImagePanelBtnMusicAlt = [NSImage imageNamed:@"Sidebar_Music_Light_Red"];
        newImagePanelBtnClock = [NSImage imageNamed:@"Sidebar_Clock_Light_Grey"];
        newImagePanelBtnClockAlt = [NSImage imageNamed:@"Sidebar_Clock_Light_Red"];
        newImagePanelBtnOSC = [NSImage imageNamed:@"Sidebar_OSC_Light_Grey"];
        newImagePanelBtnOSCAlt = [NSImage imageNamed:@"Sidebar_OSC_Light_Red"];
        newImagePanelBtnTerminal = [NSImage imageNamed:@"Sidebar_Terminal_Light_Grey"];
        newImagePanelBtnTerminalAlt = [NSImage imageNamed:@"Sidebar_Terminal_Light_Red"];
        newImagePanelBtnSettings = [NSImage imageNamed:@"Sidebar_Settings_Light_Grey"];
        newImagePanelBtnSettingsAlt = [NSImage imageNamed:@"Sidebar_Settings_Light_Red"];
        newImagePanelBtnBroadcast = [NSImage imageNamed:@"Sidebar_Broadcast_Light_Grey"];
        newImagePanelBtnBroadcastAlt = [NSImage imageNamed:@"Sidebar_Broadcast_Light_Red"];
    } else {
        
        newFontHeader = [fontManager fontWithFamily:@"FoundryMonoline" traits:NSItalicFontMask weight:8 size:12.0];
        newFontHeaderItalic = [fontManager fontWithFamily:@"FoundryMonoline" traits:NSItalicFontMask weight:8 size:12.0];
        newFontStandard = [fontManager fontWithFamily:@"FoundryMonoline" traits:NSUnitalicFontMask weight:8 size:10.0];
        newFontStandardItalic = [fontManager fontWithFamily:@"FoundryMonoline" traits:NSItalicFontMask weight:8 size:10.0];
        
    }

    // Set theme colors
    self.colorAlert = newColorAlert;
    self.colorError = newColorError;
    self.colorSuccess = newColorSuccess;
    
    self.colorBackground = newColorBackground;
    self.colorBackgroundAlert = newColorBackgroundAlert;
    self.colorBackgroundError = newColorBackgroundError;
    self.colorBackgroundSuccess = newColorBackgroundSuccess;
    self.colorBackgroundHover = newColorBackgroundHover;
    
    self.colorBorder = newColorBorder;
    self.colorBorderAlert = newColorBorderAlert;
    self.colorBorderError = newColorBorderError;
    self.colorBorderSuccess = newColorBorderSuccess;
    
    self.colorText = newColorText;
    self.colorTextAlert = newColorTextAlert;
    self.colorTextError = newColorTextError;
    self.colorTextSuccess = newColorTextSuccess;
    
    // Set theme fonts
    self.fontHeader = newFontHeader;
    self.fontHeaderItalic = newFontHeaderItalic;
    self.fontStandard = newFontStandard;
    self.fontStandardItalic = newFontStandardItalic;
    
    NSData *backgroundColorData=[NSArchiver archivedDataWithRootObject:self.colorBackground];
    [[NSUserDefaults standardUserDefaults] setObject:backgroundColorData forKey:Preference_Key_Color_Background];
    
    // Set theme images
    self.imagePanelBtnManual = newImagePanelBtnManual;
    self.imagePanelBtnManualAlt = newImagePanelBtnManualAlt;
    self.imagePanelBtnGroup = newImagePanelBtnGroup;
    self.imagePanelBtnGroupAlt = newImagePanelBtnGroupAlt;
    self.imagePanelBtnUser = newImagePanelBtnUser;
    self.imagePanelBtnUserAlt = newImagePanelBtnUserAlt;
    self.imagePanelBtnChat = newImagePanelBtnChat;
    self.imagePanelBtnChatAlt = newImagePanelBtnChatAlt;
    self.imagePanelBtnSocial = newImagePanelBtnSocial;
    self.imagePanelBtnSocialAlt = newImagePanelBtnSocialAlt;
    self.imagePanelBtnMap = newImagePanelBtnMap;
    self.imagePanelBtnMapAlt = newImagePanelBtnMapAlt;
    self.imagePanelBtnRoute = newImagePanelBtnRoute;
    self.imagePanelBtnRouteAlt = newImagePanelBtnRouteAlt;
    self.imagePanelBtnVideo = newImagePanelBtnVideo;
    self.imagePanelBtnVideoAlt = newImagePanelBtnVideoAlt;
    self.imagePanelBtnMusic = newImagePanelBtnMusic;
    self.imagePanelBtnMusicAlt = newImagePanelBtnMusicAlt;
    self.imagePanelBtnClock = newImagePanelBtnClock;
    self.imagePanelBtnClockAlt = newImagePanelBtnClockAlt;
    self.imagePanelBtnOSC = newImagePanelBtnOSC;
    self.imagePanelBtnOSCAlt = newImagePanelBtnOSCAlt;
    self.imagePanelBtnTerminal = newImagePanelBtnTerminal;
    self.imagePanelBtnTerminalAlt = newImagePanelBtnTerminalAlt;
    self.imagePanelBtnBroadcast = newImagePanelBtnBroadcast;
    self.imagePanelBtnBroadcastAlt = newImagePanelBtnBroadcastAlt;
    
    // Shout it out to the world!
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AMThemeChanged" object:self];
}

@end
