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
#import "AMNetworkToolsCommand.h"
#import "AMCommonTools/AMCommonTools.h"

@interface AMPingTabVC : NSViewController 

@end

@interface AMUserListItem : NSObject
@property AMLiveUser*       user;
@property NSTextField*      nickNameTF;
@property AMCheckBoxView*   checkbox;
@end

@protocol AMUserListDelegate <NSObject>
//-(void) outputString:(NSString*) output;
- (BOOL) useIPV6;
-(NSString*) formatCommand:(NSString*) ip;
@end

@interface AMUserList : NSObject<NSTableViewDataSource, NSTableViewDelegate>
{
  //  NSTableView*   tableView;
    
    //for user list
    NSInteger           _selectedIndex;
    NSString*           _lastName;
}
@property id<AMUserListDelegate> delegate;
-(void)executeCommand : (NSString*) command;
- (instancetype) init:(NSTableView*) tv;

@property (weak)         NSTableView*   tableView;
@property NSMutableArray*     userList;
@property AMNetworkToolsCommand *     pingCommand;
-(void)userGroupsChangedPing:(NSNotification*)notification;
@end
