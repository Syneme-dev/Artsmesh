//
//  AMStatusNetSettingsVC.m
//  Artsmesh
//
//  Created by 王为 on 11/2/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMAccountSettingsVC.h"
#import "AMStatusNet/AMStatusNet.h"
#import "UIFramework/AMButtonHandler.h"
#import "UIFramework/AMBlueBorderButton.h"


@interface AMAccountSettingsVC ()
@property (weak) IBOutlet NSButton *postBtn;
@property (weak) IBOutlet AMBlueBorderButton *googleBtn;
@property (weak) IBOutlet NSTextField *postResField;

@end

@implementation AMAccountSettingsVC
{
    NSString *kKeychainItemName;
    NSString *scope;
    NSString *kMyClientID;
    NSString *kMyClientSecret;
}

-(void)awakeFromNib
{
    //Set up YouTube/oAuth stuff
    kKeychainItemName = @"ArtsMesh: YouTube";
    
    scope = @"https://www.googleapis.com/auth/youtube";
    kMyClientID = @"998042950112-nf0sggo2f56tvt8bcord9kn0qe528mqv.apps.googleusercontent.com";
    kMyClientSecret = @"P1QKHOBVo-1RTzpz9sOde4JP";
    
    // Get the saved authentication, if any, from the keychain.
    GTMOAuth2Authentication *auth;
    auth = [GTMOAuth2WindowController authForGoogleFromKeychainForName:kKeychainItemName
                                                              clientID:kMyClientID
                                                          clientSecret:kMyClientSecret];
    
    [self setAuthentication:auth];
    [self updateUI];
}

- (void)webViewClose:(WebView *)sender {
    
    [super webViewClose:sender];
}

- (void)windowController:(GTMOAuth2WindowController *)windowController
        finishedWithAuth:(GTMOAuth2Authentication *)auth
                   error:(NSError *)error {
    if (error != nil) {
        // Authentication failed
        [self setAuthentication:nil];
    } else {
        // Authentication succeeded
        [self setAuthentication:auth];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:AM_GOOGLE_ACCOUNT_CHANGED object:auth];
        
        [self updateUI];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [AMButtonHandler changeTabTextColor:self.postBtn toColor:UI_Color_blue];
}


- (IBAction)statusNetTest:(id)sender {
//    BOOL res = [[AMStatusNet shareInstance]
//                postMessageToStatusNet:@"This is a test message send from Artsmesh through API"];
//    if (res)
//    {
//        self.postResField.stringValue = @"Post Succeeded!";
//    }
//    else
//    {
//        self.postResField.stringValue = @"Post Failed!";
//    }
}

- (IBAction)googleBtnClick:(id)sender {
    // Fires when Google Login/Logout button is clicked
    if ([self isSignedIn]) {
        [self signOut];
    } else {
        [self loadOAuthWindow];
    }
}

- (void)loadOAuthWindow {
    NSApplication *myApp = [NSApplication sharedApplication];
    NSWindow *curWindow = [myApp keyWindow];
    
    GTMOAuth2WindowController *windowController;
    windowController = [[GTMOAuth2WindowController alloc] initWithScope:scope
                                                               clientID:kMyClientID
                                                           clientSecret:kMyClientSecret
                                                       keychainItemName:kKeychainItemName
                                                         resourceBundle:nil];
    
    [windowController signInSheetModalForWindow:curWindow
                                       delegate:self
                               finishedSelector:@selector(windowController:finishedWithAuth:error:)];
}

- (void)setAuthentication:(GTMOAuth2Authentication *)auth {
    mAuth = auth;
}

- (void)signOut {
    if ([mAuth.serviceProvider isEqual:kGTMOAuth2ServiceProviderGoogle]) {
        // Remove the token from Google's servers
        [GTMOAuth2WindowController revokeTokenForGoogleAuthentication:mAuth];
    }
    
    // Remove the stored Google authentication from the keychain, if any
    [GTMOAuth2WindowController removeAuthFromKeychainForName:kKeychainItemName];
    
    // Discard our retained authentication object
    [self setAuthentication:nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AM_GOOGLE_ACCOUNT_CHANGED object:nil];
    
    [self updateUI];
    
}

- (void)updateUI {
    [self checkLoginInBtn];
}

- (void)checkLoginInBtn {
    if ( [self isSignedIn] ) {
        [self.googleBtn setTitle:@"LOGOUT"];
    } else {
        [self.googleBtn setTitle:@"LOGIN"];
    }
    
    [AMButtonHandler changeTabTextColor:self.googleBtn toColor:UI_Color_blue];
    [self.view setNeedsDisplay:TRUE];
}

- (BOOL)isSignedIn {
    BOOL isSignedIn = mAuth.canAuthorize;
    return isSignedIn;
}

@end
