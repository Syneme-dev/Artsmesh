//
//  CEAppDelegate.h
//  httprequest
//
//  Created by Wei Wang on 6/13/14.
//  Copyright (c) 2014 AM. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CEAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *rootURL;
@property (weak) IBOutlet NSTextField *groupId;
@property (weak) IBOutlet NSTextField *groupName;
@property (weak) IBOutlet NSTextField *superGroupId;
@property (weak) IBOutlet NSTextField *userId;
@property (weak) IBOutlet NSTextField *userData;
@property (weak) IBOutlet NSComboBox *operation;
@property (unsafe_unretained) IBOutlet NSTextView *resultView;

- (IBAction)sendRequest:(id)sender;
- (IBAction)createGroupId:(id)sender;
- (IBAction)createUserId:(id)sender;
- (IBAction)clearResult:(id)sender;

@end
