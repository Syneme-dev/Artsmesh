//
//  AMUserViewController.m
//  DemoUI
//
//  Created by 王 为 on 3/31/14.
//  Copyright (c) 2014 Artsmesh. All rights reserved.
//

#import "AMUserViewController.h"

#import <AMNotificationManager/AMNotificationManager.h>
#import "AMRestHelper.h"
#import "AFHTTPRequestOperationManager.h"
#import <UIFramework/AMButtonHandler.h>

@interface AMUserViewController ()

@end

@implementation AMUserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}


-(void)awakeFromNib
{
    [self.statusMessageLabel setFont: [NSFont fontWithName: @"FoundryMonoline" size: self.statusMessageLabel.font.pointSize]];
     [AMButtonHandler changeTabTextColor:self.userTabButton toColor:UI_Color_blue];
    [AMButtonHandler changeTabTextColor:self.groupTabButton toColor:UI_Color_blue];
    [self loadAvatarImage];
}
//Note:sample code if using this as notification.
//-(void)onUpdateUserAVator:(NSNotification*)notification{
//    
//
//    NSDictionary* user=notification.userInfo;
//    NSString *imageUrlString=[user valueForKey:@"profile_image_url"];
//    NSURL* imageUrl=[NSURL URLWithString:[imageUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//    NSData *imageData = [imageUrl resourceDataUsingCache:NO];
//    NSImage *imageFromBundle = [[NSImage alloc] initWithData:imageData];
//    [self.avatarView  setImage:imageFromBundle];
//    
////http://artsmesh.io//theme/dark/default-avatar-profile.png
//}

-(void)loadAvatarImage{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *myAccountUrl=[AMRestHelper getMyAccountInfoUrl];
    [manager GET:myAccountUrl parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *imageUrlString=[responseObject valueForKey:@"profile_image_url"];
        [self loadAvatarFromUrl:imageUrlString];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

-(void)loadAvatarFromUrl:(NSString*)imageUrlString{
    NSURL* imageUrl=[NSURL URLWithString:[imageUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData *imageData = [imageUrl resourceDataUsingCache:NO];
    NSImage *imageFromBundle = [[NSImage alloc] initWithData:imageData];
    [self.avatarView  setImage:imageFromBundle];
}

- (IBAction)onUserTabClick:(id)sender {
    [self.tabs selectTabViewItemAtIndex:0];
}

- (IBAction)onGroupTabClick:(id)sender {
    
    [self.tabs selectTabViewItemAtIndex:1];
}
@end
