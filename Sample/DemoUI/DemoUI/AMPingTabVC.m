//
//  AMPingTabVC.m
//  Artsmesh
//
//  Created by whiskyzed on 6/8/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMPingTabVC.h"


#import "AMNetworkToolsCommand.h"
#import "AMCommonTools/AMCommonTools.h"

#import "UIFramework/AMFoundryFontView.h"
#import "UIFramework/AMCheckBoxView.h"
#import "UIFramework/AMRatioButtonView.h"
#import "UIFramework/AMUIConst.h"

@interface AMPingTabVC () <NSTableViewDataSource, NSTableViewDelegate,
                            AMCheckBoxDelegeate>
{
    AMNetworkToolsCommand *     _pingCommand;
    
    //for user list
    NSMutableArray*     _userList;
    NSInteger           _selectedIndex;
    NSString*           _lastName;
}

@property (weak)                IBOutlet NSTableView*   tableView;
@property (unsafe_unretained)   IBOutlet NSTextView *   pingContentView;
@end

@implementation AMUserListItem

- (instancetype) init
{
    if (self = [super init]) {
        NSRect rect = NSMakeRect(0, 0, 30, 30);
        self.checkbox = [[AMCheckBoxView alloc] initWithFrame:rect];
    }
    return self;
}

@end


@implementation AMPingTabVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    _pingCommand = [[AMNetworkToolsCommand alloc] init];
    _pingCommand.contentView = self.pingContentView;
    
    
     [[NSNotificationCenter defaultCenter]
                                addObserver:self
                                selector:@selector(userGroupsChangedPing:)
                                name: AM_LIVE_GROUP_CHANDED
                                object:nil];
    
    AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    if (mySelf.isOnline)
    {
        [self userGroupsChangedPing:nil];
    }
    
    _userList = [[NSMutableArray alloc] init];
}


-(CGFloat)heightOfTextFieldWithString:(NSString *)string width:(CGFloat)width font:(NSFont *)font
{
    NSTextField *textField = [[NSTextField alloc] initWithFrame:CGRectMake(0, 0, width, 1000)];
    textField.font = font;
    textField.stringValue = string;
    NSSize size = [textField.cell cellSizeForBounds:textField.frame];
    return size.height;
}


- (NSTextField*) newNameTextField : (NSString*) name
{
    NSFont *font = [NSFont fontWithName:@"FoundryMonoline"
                                   size:12.0f];
    NSUInteger colIndex = [self.tableView columnWithIdentifier:@"userName"];
    CGFloat width = [[[self.tableView tableColumns] objectAtIndex:colIndex] width];
    CGFloat height = [self heightOfTextFieldWithString:name
                                                 width:width font:font];
    NSTextField* field = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 2, width, height)];
    
    field.font = font;
    field.bordered = NO;
    field.editable = NO;
    field.backgroundColor = [NSColor clearColor];
    [field setFocusRingType:NSFocusRingTypeNone];
    [field setTextColor:LIGHT_GRAY];
    [field setStringValue:name];
    
    return field;
}

-(void)userGroupsChangedPing:(NSNotification*)notification
{
    AMLiveGroup* mergedGroup = [[AMCoreData shareInstance] mergedGroup];
    NSArray* users = [mergedGroup usersIncludeSubGroup];
    [_userList removeAllObjects];
    for (AMLiveUser* liveUser in users) {
        AMUserListItem* item = [[AMUserListItem alloc] init];
        item.user = liveUser;
        item.checkbox.delegate = self;
        item.nickNameTF = [self newNameTextField:liveUser.nickName];
        
        [_userList addObject:item];
    }
    
    [self.tableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return _userList.count;
}

- (id)tableView:(NSTableView *)tableView
viewForTableColumn:(NSTableColumn *)tableColumn
            row:(NSInteger)row
{
    if ([tableColumn.identifier isEqualToString:@"userName"]) {
        static NSString *cellIdentifier = @"name_cell";
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:cellIdentifier
                                                                owner:self];
        if (cellView == nil)
        {
            NSRect cellFrame = NSMakeRect(0, 0, 100, 30);
            cellView = [[NSTableCellView alloc] initWithFrame:cellFrame];
            [cellView setIdentifier:cellIdentifier];
        }
        
        AMUserListItem* item = [_userList objectAtIndex:row];
        AMLiveUser* user = item.user;
        [cellView addSubview:item.nickNameTF];
        
        return cellView;
        
    }else{
        static NSString *cellIdentifier = @"check_cell";
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:cellIdentifier
                                                                owner:self];
        
        if (cellView == nil)
        {
            NSRect cellFrame = NSMakeRect(0, 0, 30, 30);
            cellView = [[NSTableCellView alloc] initWithFrame:cellFrame];
            [cellView setIdentifier:cellIdentifier];
        }
        
        AMUserListItem* userItem = [_userList objectAtIndex:row];
        AMCheckBoxView* check = userItem.checkbox;
        
        NSRect frameRect = NSMakeRect(0, 0, 30, 30);
        check.frame = frameRect;
        
        [cellView addSubview:check];

        return cellView;
    }
    
    return nil;
}

- (void) onChecked:(AMCheckBoxView *)sender
{
    if (sender.checked == NO) {
        sender.checked = YES;
    }
    
    for (AMUserListItem* userItem in _userList) {
        if([userItem.checkbox isEqual:sender]){
            NSString* ip = userItem.user.publicIp;
            NSString *command;
            
            if ([AMCommonTools isValidIpv4:ip]){
                command = [NSString stringWithFormat:@"ping -c 5 %@", ip];
            }else{
                command = [NSString stringWithFormat:@"ping6 -c 5 %@", ip];
            }
            
            [_pingCommand stop];
            _pingCommand.command = command;
            [_pingCommand run];
        }else{
            userItem.checkbox.checked = NO;
        }
            
    }
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
}




@end
