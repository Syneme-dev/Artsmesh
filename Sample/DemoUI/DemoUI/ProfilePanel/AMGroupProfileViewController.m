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
#import "AMCoreData/AMCoredata.h"
#import "AMPreferenceManager/AMPreferenceManager.h"
#import "AMStatusNet/AMStatusNet.h"
#import "AMMesher/AMMesher.h"

@interface AMGroupProfileViewController ()<AMCheckBoxDelegeate>
@property (weak) IBOutlet NSImageView *groupAvatar;
@property (weak) IBOutlet AMFoundryFontView *groupNameField;
@property (weak) IBOutlet AMFoundryFontView *fullNameField;
@property (weak) IBOutlet AMFoundryFontView *homePageField;
@property (weak) IBOutlet AMFoundryFontView *locationField;
@property (weak) IBOutlet AMCheckBoxView *lockBox;
@property (weak) IBOutlet NSImageView *statusLight;
@property (weak) IBOutlet AMFoundryFontView *descriptionField;


@end

@implementation AMGroupProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    [self loadAvatar];
    [self setLockBox];
    [self setStatus];
    
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(groupChanged:) name:AM_LIVE_GROUP_CHANDED object:nil];
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
        [self.statusLight setImage:[NSImage imageNamed:@"groupuser_busy"]];
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
}


-(void)onChecked:(AMCheckBoxView*)sender
{
    AMLiveGroup *myLocalGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    myLocalGroup.busy = sender.checked;

    [[AMMesher sharedAMMesher] updateGroup];
    [self startBlickingStatus];
}


- (IBAction)groupNameChanged:(id)sender
{
    NSString *newName = [sender stringValue];
    AMLiveGroup* myGroup = [AMCoreData shareInstance].myLocalLiveGroup;
    
    if ([myGroup.groupName isEqualToString:newName]) {
        return;
    }
    
    if ([newName isEqualToString:@""]) {
        newName = [[AMPreferenceManager standardUserDefaults]
                              stringForKey:Preference_Key_Cluster_Name];
        self.groupNameField.stringValue = newName;
        
    }
    
    myGroup.groupName = newName;
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
        myGroup.location = sender.stringValue;
    }
    
    [self getCoordinates: sender.stringValue];
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
        group.groupName = sender.stringValue;
    }
    
    group.description = sender.stringValue;
    [[AMMesher sharedAMMesher] updateGroup];
    
    [self startBlickingStatus];
}


-(void)startBlickingStatus
{
    [self.statusLight setImage:[NSImage imageNamed:@"synchronizing_icon"]];
    [self performSelector:@selector(setStatus) withObject:nil afterDelay:1];
}


- (void)getCoordinates:(NSString *)searchTerm
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
    NSArray *geoData = [NSJSONSerialization JSONObjectWithData:response options:0 error:&jsonParsingError];
    
    if(jsonParsingError != nil){
        NSLog(@"Geo data parse JSON error:%@", jsonParsingError.description);
    }
    NSDictionary *results = (NSDictionary*)geoData;
    NSArray *geoNames = [results valueForKey:@"geonames"];
    
    if (geoNames == nil || [geoNames count] == 0) {
        return;
    }
    
    NSDictionary *topResult = [geoNames objectAtIndex:0];
    
    if ( [topResult count] >= 1 ) {
        AMLiveGroup* myGroup = [AMCoreData shareInstance].myLocalLiveGroup;
        
        double lat = [[topResult valueForKey:@"lat"] doubleValue];
        double lon = [[topResult valueForKey:@"lng"] doubleValue];
        
        myGroup.location = searchTerm;
        myGroup.longitude = [NSString stringWithFormat:@"%f", lon];
        myGroup.latitude =  [NSString stringWithFormat:@"%f", lat];
        
        //NSLog(@"location data is: %@", topResult);
        //NSLog(@"saved lat/lon is: %f, %f", lat, lon);
        
        [[AMMesher sharedAMMesher] updateGroup];
        
        [[AMPreferenceManager standardUserDefaults]
         setObject:myGroup.longitude forKey:Preference_Key_Cluster_Longitude];
        [[AMPreferenceManager standardUserDefaults]
         setObject:myGroup.latitude forKey:Preference_Key_Cluster_Latitude];
    } else {
        //No result found
    }
}


@end
