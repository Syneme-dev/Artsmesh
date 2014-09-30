//
//  AMPreferenceManager.h
//  AMPreferenceManager
//
//  Created by Sky JIA on 12/30/13.
//  Copyright (c) 2013 Artsmesh. All rights reserved.
//


//General
#define Preference_Key_General_UseIpv6              @"Preference_Key_General_UseIpv6"
#define Preference_Key_General_MachineName          @"Preference_Key_General_MachineName"
#define Preference_Key_General_LocalServerPort      @"Preference_Key_General_LocalServerPort"
#define Preference_Key_General_GlobalServerAddr     @"Preference_Key_General_GlobalServerAddr"
#define Preference_Key_General_GlobalServerPort     @"Preference_Key_General_GlobalServerPort"
#define Preference_Key_General_ChatPort             @"Preference_Key_General_ChatPort"
#define Preference_Key_General_StunServerAddr       @"Preference_Key_General_StunServerAddr"
#define Preference_Key_General_StunServerPort       @"Preference_Key_General_StunServerPort"
#define Preference_Key_General_TopControlBar        @"Preference_Key_General_TopControlBar"

//UserInfo
#define Preference_Key_User_NickName            @"Preference_Key_User_NickName"
#define Preference_Key_User_Affiliation         @"Preference_Key_User_Affiliation"
#define Preference_Key_User_Location            @"Preference_Key_User_Location"
#define Preference_Key_User_FullName            @"Preference_Key_User_FullName"
#define Preference_Key_User_Description         @"Preference_Key_User_Description"
#define Preference_Key_User_PrivateIp           @"Preference_Key_User_PrivateIp"

#define Preference_Key_Cluster_Name             @"Preference_Key_Cluster_Name"
#define Preference_Key_Cluster_Description      @"Preference_Key_Cluster_Description"
#define Preference_Key_Cluster_FullName         @"Preference_Key_Cluster_FullName"
#define Preference_Key_Cluster_Project          @"Preference_Key_Cluster_Project"
#define Preference_Key_Cluster_Location         @"Preference_Key_Cluster_Location"

//StatusNest
#define Preference_Key_StatusNet_URL            @"Preference_Key_StatusNet_URL"
#define Preference_Key_StatusNet_UserName       @"Preference_Key_StatusNet_UserName"
#define Preference_Key_StatusNet_Password       @"Preference_Key_StatusNet_Password"

//default
#define Preference_User_Affiliation         @"YourAffiliation"
#define Preference_User_Description         @"This is my biography."
#define Preference_User_Status              @"Online"
#define Preference_User_Location            @"YourLocation"
#define Preference_User_NickName            @"YourNickName"
#define Preference_User_FullName            @"YourFullName"

#define Preference_General_ChatPort         @"22260"
#define Preference_User_PrivateIp           @""
#define Preference_User_PublicIp            @""
#define Preference_User_LocalLeader         @""
#define Preference_Cluster_Name             @"LocalGroup"
#define Preference_Cluster_Description      @"There is no description of the group"
#define Preference_Cluster_FullName         @"Full Name"
#define Preference_Cluster_Location         @"Location"
#define Preference_Cluster_Project          @"Project"

#define Preference_General_StunServerAddr   @"Artsmesh.io"
#define Preference_General_StunServerPort   @"22250"
#define Preference_General_GlobalServerAddr   @"Artsmesh.io"
#define Preference_General_GlobalServerPort   @"8080"
#define Preference_General_LocalServerPort    @"9090"
#define Preference_General_TopControlBar   @"YES"

#define Preference_StatusNet_URL            @"http://artsmesh.io"

#define UserData_Key_OpenedPanel    @"UserData_Key_OpenedPanel"



/////////////////////////Audio Preference///////////////////////////////////////
#define Preference_Jack_Driver          @"Preference_Jack_Driver"
#define Preference_Jack_InputDevice     @"Preference_Jack_InputDevice"
#define Preference_Jack_OutputDevice    @"Preference_Jack_OutputDevice"
#define Preference_Jack_SampleRate      @"Preference_Jack_SampleRate"
#define Preference_Jack_BufferSize      @"Preference_Jack_BufferSize"
#define Preference_Jack_HogMode         @"Preference_Jack_HogMode"
#define Preference_Jack_ClockDriftComp  @"Preference_Jack_ClockDriftComp"
#define Preference_Jack_PortMoniting    @"Preference_Jack_PortMoniting"
#define Preference_Jack_ActiveMIDI      @"Preference_Jack_ActiveMIDI"
#define Preference_Jack_InterfaceInChans  @"Preference_Jack_InterfaceChans"
#define Preference_Jack_InterfaceOutChanns @"Preference_Jack_InterfaceOutChanns"


#import <Foundation/Foundation.h>

@interface AMPreferenceManager : NSObject

+(AMPreferenceManager*)shareInstance;
+(NSUserDefaults *)standardUserDefaults;

-(void)initPreference;

@end
