//
//  AMGroupProfileViewController.m
//  DemoUI
//
//  Created by 王为 on 23/1/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMGroupProfileViewController.h"
#import "UIFramework/AMCheckBoxView.h"
#import "UIFramework/AMFoundryFontView.h"
#import "UIFramework/AMBlinkView.h"
#import "AMCoreData/AMCoredata.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "AMStatusNet/AMStatusNet.h"
#import "AMMesher/AMMesher.h"
#import "AMNotificationManager/AMNotificationManager.h"
#import "AMGroupCreateViewController.h"


@interface AMGroupProfileViewController ()<AMCheckBoxDelegeate, NSPopoverDelegate,
                                            AMBlinkViewDelegate>
@property (weak) IBOutlet NSImageView *groupAvatar;
@property (weak) IBOutlet AMFoundryFontView *   groupNameField;
@property (weak) IBOutlet AMFoundryFontView *   fullNameField;
@property (weak) IBOutlet AMFoundryFontView *   homePageField;
@property (weak) IBOutlet AMFoundryFontView *   locationField;
@property (weak) IBOutlet AMCheckBoxView *      lockBox;
@property (weak) IBOutlet AMBlinkView*          statusLight;
@property (weak) IBOutlet AMFoundryFontView *   descriptionField;

@property NSPopover *myPopover;

@end

@implementation AMGroupProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupChanged:) name:AM_LIVE_GROUP_CHANDED object:nil];
    [self groupChanged:nil];
    self.statusLight.blinkDelegate = self;
}


-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


-(void)loadAvatar
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString * myGroupName = [defaults stringForKey:Preference_Key_Cluster_Name];
    
    [[AMStatusNet shareInstance] loadGroupAvatar:myGroupName requestCallback:^(NSImage* image, NSError* err){
        if (err != nil) {
            return;
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.groupAvatar setImage:image];
            });
        }
    }];
}


-(void)setLockBox
{
    self.lockBox.title = @"LOCK";
    self.lockBox.delegate = self;
    
    AMLiveGroup* localGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    self.lockBox.checked = localGroup.busy;
}


-(void)setStatus
{
    AMLiveGroup* localGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    if (localGroup.busy) {
        [self.statusLight setImage:[NSImage imageNamed:@"group_lock_dot"]];
    }else if([localGroup hasUserOnline]){
        [self.statusLight setImage:[NSImage imageNamed:@"groupuser_meshed_icon"]];
    }else{
        [self.statusLight setImage:[NSImage imageNamed:@"group_unmeshed_icon"]];
    }
}


-(void)groupChanged:(NSNotification *)notification
{
    [self loadAvatar];
    [self setLockBox];
    [self setStatus];
    
    AMLiveGroup *myGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    NSUserDefaults *defaults = [AMPreferenceManager standardUserDefaults];
    [defaults setObject:myGroup.groupName forKey:Preference_Key_Cluster_Name];
    [defaults setObject:myGroup.fullName forKey:Preference_Key_Cluster_FullName];
    [defaults setObject:myGroup.description forKey:Preference_Key_Cluster_Description];
    [defaults setObject:myGroup.homePage forKey:Preference_Key_Cluster_HomePage];
    [defaults setObject:myGroup.location forKey:Preference_Key_Cluster_Location];
    
    [self setGroupLongitudeAndLatitude:myGroup.location];
}


-(void)onChecked:(AMCheckBoxView*)sender
{
    AMLiveGroup *myLocalGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    myLocalGroup.busy = sender.checked;

    [[AMMesher sharedAMMesher] updateGroup];
    [self startBlickingStatus];
}


- (IBAction)groupNameChanged:(NSTextField *)sender
{
    AMLiveGroup* myGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    if ([myGroup.groupName isEqualToString:sender.stringValue]) {
        return;
    }
    
    if ([sender.stringValue isEqualToString:@""]) {
        sender.stringValue = [[AMPreferenceManager standardUserDefaults]
                              stringForKey:Preference_Key_Cluster_Name];
    }
    
    myGroup.groupName = sender.stringValue;
    [[AMMesher sharedAMMesher] updateGroup];
    
    [self startBlickingStatus];
}


- (IBAction)fullNameChanged:(NSTextField *)sender
{
    AMLiveGroup* group = [AMCoreData shareInstance].myLocalLiveGroup;
    if ([group.fullName isEqualToString:sender.stringValue]) {
        return;
    }
    
    if ([sender.stringValue isEqualToString:@""]) {
        sender.stringValue = [[AMPreferenceManager standardUserDefaults]
                              stringForKey:Preference_Key_Cluster_FullName];
    }
    
    group.fullName = sender.stringValue;
    [[AMMesher sharedAMMesher] updateGroup];
    
    [self startBlickingStatus];
}


- (IBAction)homePageChanged:(NSTextField *)sender
{
    AMLiveGroup* group = [AMCoreData shareInstance].myLocalLiveGroup;
    if ([group.homePage isEqualToString:sender.stringValue]) {
        return;
    }
    
    if ([sender.stringValue isEqualToString:@""]) {
        sender.stringValue = [[AMPreferenceManager standardUserDefaults]
                              stringForKey:Preference_Key_Cluster_HomePage];
    }
    
    group.homePage= sender.stringValue;
    [[AMMesher sharedAMMesher] updateGroup];
    
    [self startBlickingStatus];
}


- (IBAction)locationChanged:(NSTextField *)sender
{
    AMLiveGroup* myGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    if ([myGroup.location isEqualToString:sender.stringValue]) {
        return;
    }
    
    if ([sender.stringValue isEqualToString:@""]) {
        sender.stringValue = [[AMPreferenceManager standardUserDefaults]
                              stringForKey:Preference_Key_Cluster_Location];
    }
    
    [self setGroupLongitudeAndLatitude: sender.stringValue];
    [[AMMesher sharedAMMesher] updateGroup];
}


- (IBAction)descriptionChanged:(NSTextField *)sender
{
    AMLiveGroup* group = [AMCoreData shareInstance].myLocalLiveGroup;
    
    if ([group.description isEqualToString:sender.stringValue]) {
        return;
    }
    
    if ([sender.stringValue isEqualToString:@""]) {
        sender.stringValue = [[AMPreferenceManager standardUserDefaults]
                              stringForKey:Preference_Key_Cluster_Description];
    }
    
    group.description = sender.stringValue;
    [[AMMesher sharedAMMesher] updateGroup];
    
    [self startBlickingStatus];
}

#pragma mark  -
#pragma mark  blink-start
-(void)startBlickingStatus
{
/*    [self.statusLight setImage:[NSImage imageNamed:@"synchronizing_icon"]];
    [self performSelector:@selector(setStatus) withObject:nil afterDelay:1];*/
    [self.statusLight startBlink];
}

- (void) afterStopBlink
{
    [self setStatus];
    [self.statusLight setNeedsDisplay:YES];
}
#pragma mark  -


-(void)setGroupLongitudeAndLatitude:(NSString *)location
{
    NSDictionary *geoInfo = [self getCoordinates: location];
    if (geoInfo) {
        AMLiveGroup* myGroup = [AMCoreData shareInstance].myLocalLiveGroup;
        
        double lat = [[geoInfo valueForKey:@"lat"] doubleValue];
        double lon = [[geoInfo valueForKey:@"lng"] doubleValue];
        
        myGroup.location = location;
        myGroup.longitude = [NSString stringWithFormat:@"%f", lon];
        myGroup.latitude =  [NSString stringWithFormat:@"%f", lat];
        
        [[AMPreferenceManager standardUserDefaults]
         setObject:myGroup.longitude forKey:Preference_Key_Cluster_Longitude];
        [[AMPreferenceManager standardUserDefaults]
         setObject:myGroup.latitude forKey:Preference_Key_Cluster_Latitude];
    }
}


- (NSDictionary *)getCoordinates:(NSString *)searchTerm
{
    NSString *username = @"artsmesh";
    
    NSString *searchURL = [NSString stringWithFormat:@"%@%@%@%@",
                           @"http://api.geonames.org/searchJSON?name=",
                           searchTerm,
                           @"&maxRows=1&username=",
                           username];
    
    NSString *searchUTF8 = [searchURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:searchUTF8]];
    
    NSData *response = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:nil error:nil];
    
    NSError *jsonParsingError = nil;
    
    if (response == nil) {
        return nil;
    }
    
    NSArray *geoData = [NSJSONSerialization JSONObjectWithData:response options:0 error:&jsonParsingError];
    
    if(jsonParsingError != nil){
        NSLog(@"Geo data parse JSON error:%@", jsonParsingError.description);
        return nil;
    }
    
    NSDictionary *results = (NSDictionary*)geoData;
    NSArray *geoNames = [results valueForKey:@"geonames"];
    
    if (geoNames == nil || [geoNames count] == 0) {
        return nil;
    }
    
    return [geoNames firstObject];
}

- (IBAction)socialBtnClicked:(id)sender
{
    NSString* groupName = self.groupNameField.stringValue;
    
    for (AMStaticGroup* sg in [AMCoreData shareInstance].staticGroups) {
        if ([sg.nickname isEqualToString:groupName]) {
            NSDictionary *userInfo= [[NSDictionary alloc] initWithObjectsAndKeys:
                                     groupName, @"GroupName", nil];
            [AMN_NOTIFICATION_MANAGER postMessage:userInfo withTypeName:AMN_SHOWGROUPINFO source:self];
            return;
        }
    }
    
    [self popoverGroupRegisterView:sender];
}

-(void)popoverGroupRegisterView:(id)sender
{
    if (self.myPopover == nil) {
        self.myPopover = [[NSPopover alloc] init];
        
        self.myPopover.animates = YES;
        self.myPopover.behavior = NSPopoverBehaviorTransient;
        //! self.myPopover.appearance = NSPopoverAppearanceHUD;
        self.myPopover.delegate = self;
    }
    
    self.myPopover.contentViewController = [[AMGroupCreateViewController alloc] initWithNibName:@"AMGroupCreateViewController" bundle:nil];
    
    NSButton *targetButton = (NSButton*)sender;
    NSRectEdge prefEdge = NSMaxXEdge;
    [self.myPopover showRelativeToRect:[targetButton bounds] ofView:sender preferredEdge:prefEdge];
}

- (void)popoverWillShow:(NSNotification *)notification
{
    if([self.myPopover.contentViewController isKindOfClass:[AMGroupCreateViewController class]]){
        AMGroupCreateViewController* popController = (AMGroupCreateViewController*)self.myPopover.contentViewController;
        if (popController != nil) {
            
            NSUserDefaults* defaults = [AMPreferenceManager standardUserDefaults];
            NSString* groupname = [defaults stringForKey:Preference_Key_Cluster_Name];
            popController.nickName = groupname;
        }
    }
}

-(void)popoverDidClose:(NSNotification *)notification
{
    [self loadAvatar];
}


@end
