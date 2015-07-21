//
//  AMUserList.h
//  Artsmesh
//
//  Created by whiskyzed on 7/21/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMNetworkToolsCommand.h"
#import "UIFramework/AMCheckBoxView.h"
#import "AMCoreData/AMCoreData.h"
#import "AMCommonTools/AMCommonTools.h"

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


@interface AMUserList : NSObject<NSTableViewDataSource, NSTableViewDelegate, AMCheckBoxDelegeate>
{
    //  NSTableView*   tableView;
    
    //for user list
    NSInteger           _selectedIndex;
    NSString*           _lastName;
    
    //User defined checkbox and TextField
    AMCheckBoxView*     _userDefinedCheck;
    NSTextField*        _userDefinedTF;
}

@property id<AMUserListDelegate> delegate;
-(void)executeCommand : (NSString*) command;
- (instancetype) init:(NSTableView*) tv;
- (instancetype) init:(NSTableView*) tv
           inputField:(NSView*) view;

@property (weak)         NSTableView*   tableView;
@property NSMutableArray*     userList;
@property AMNetworkToolsCommand *     pingCommand;
-(void)userGroupsChangedPing:(NSNotification*)notification;
@end
