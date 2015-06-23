//
//  AMPingTabVC.h
//  Artsmesh
//
//  Created by whiskyzed on 6/8/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "UIFramework/AMCheckBoxView.h"
#import "AMCoreData/AMCoreData.h"

@interface AMPingTabVC : NSViewController 

@end



@interface AMUserListItem : NSObject
@property AMLiveUser*       user;
@property NSTextField*      nickNameTF;
@property AMCheckBoxView*   checkbox;
@end

