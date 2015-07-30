//
//  AMStatusNetSettingsVC.h
//  Artsmesh
//
//  Created by 王为 on 11/2/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <GTL/GTMOAuth2WindowController.h>
#import "GTLYouTube.h"

@interface AMAccountSettingsVC : NSViewController {
    @private GTMOAuth2Authentication *mAuth;
}

@end
