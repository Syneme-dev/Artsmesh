//
//  AMPingTabVC.m
//  Artsmesh
//
//  Created by whiskyzed on 6/8/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMPingTabVC.h"



#import "UIFramework/AMFoundryFontView.h"
#import "UIFramework/AMCheckBoxView.h"
#import "UIFramework/AMRatioButtonView.h"
#import "UIFramework/AMUIConst.h"
#import "AMCommonTools/AMCommonTools.h"

@interface AMPingTabVC () <AMCheckBoxDelegeate,AMUserListDelegate>
{
    AMUserList* userList;
}
@property (weak) IBOutlet AMCheckBoxView *useIPV6Check;
@property (weak) IBOutlet NSView *inputField;

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

@implementation AMUserList



- (instancetype) init:(NSTableView*) tv
           inputField:(NSView*) view
{
    if (self = [super init]) {
        self.tableView   = tv;
        self.userList    = [[NSMutableArray alloc] init];
        self.pingCommand = [[AMNetworkToolsCommand alloc] init];
        
        [[NSNotificationCenter defaultCenter]
                                     addObserver:self
                                        selector:@selector(userGroupsChangedPing:)
                                            name: AM_LIVE_GROUP_CHANDED
                                          object:nil];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        [self addInputField:tv FatherView:view];
    }
    return self;
}

- (instancetype) init:(NSTableView*) tv
{
    if (self = [super init]) {
        self.tableView   = tv;
        self.userList    = [[NSMutableArray alloc] init];
        self.pingCommand = [[AMNetworkToolsCommand alloc] init];
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self
         selector:@selector(userGroupsChangedPing:)
         name: AM_LIVE_GROUP_CHANDED
         object:nil];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
    }
    return self;
}

-(void) addInputField:(NSTableView*) refView FatherView:(NSView*) fview
{
    NSRect tableFrame = [refView frame];
    NSInteger height = 30;
    NSInteger width  = tableFrame.size.width;
    NSInteger xStart = tableFrame.origin.x;
    NSInteger yStart = tableFrame.origin.y + 6;
    
    NSRect  rectFrame = NSMakeRect(xStart, yStart, width, height);
   [fview setFrame:rectFrame];
    
    //Add a checkbox
    NSRect rectCheck = NSMakeRect(1, 0, 30, 30);
    _userDefinedCheck = [[AMCheckBoxView alloc] initWithFrame:rectCheck];
    _userDefinedCheck.delegate = self;
    
    //Add a text field
    NSFont *font = [NSFont fontWithName:@"FoundryMonoline"
                                   size:12.0f];
    
    CGFloat fieldHeight = [self heightOfTextFieldWithString:@"255.255.255.255"
                                                 width:width-40 font:font];
    _userDefinedTF = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 4, 130, fieldHeight)];
    
    _userDefinedTF.font = font;
    _userDefinedTF.bordered = NO;
    _userDefinedTF.editable = YES;
    _userDefinedTF.backgroundColor = UI_Color_3c4b5d;
    _userDefinedTF.drawsBackground = YES;
    [_userDefinedTF setFocusRingType:NSFocusRingTypeNone];
    [_userDefinedTF setTextColor:LIGHT_GRAY];
    

    _userDefinedTF.stringValue = @"10.0.1.13";
    NSRect rectTF = _userDefinedTF.frame;
    rectTF.origin.x += 40;
    [_userDefinedTF setFrame:rectTF];
    
    
    [fview addSubview:_userDefinedCheck];
    [fview addSubview:_userDefinedTF];
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
        
        AMUserListItem* item = [self.userList objectAtIndex:row];
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
    
    return field;
}


-(void)userGroupsChangedPing:(NSNotification*)notification
{
     AMLiveUser* mySelf = [AMCoreData shareInstance].mySelf;
    NSArray* users;
    if (mySelf.isOnline) {
        AMLiveGroup* mergedGroup = [[AMCoreData shareInstance] mergedGroup];
        users = [mergedGroup usersIncludeSubGroup];
    }else{
         AMLiveGroup *liveGroup = [AMCoreData shareInstance].myLocalLiveGroup;
         users = [liveGroup usersIncludeSubGroup];
    }
    [_userList removeAllObjects];
    for (AMLiveUser* liveUser in users) {
        AMUserListItem* item = [[AMUserListItem alloc] init];
        item.user = liveUser;
        item.checkbox.delegate = self;
        item.nickNameTF = [self newNameTextField:liveUser.nickName];
        item.nickNameTF.stringValue = liveUser.nickName;
        [_userList addObject:item];
    }
    
    [self.tableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return _userList.count;
}

/*
if you want to test with ipv6 address, it will try its best to (local, remote or public).
test with local group ipv4, you have to use the local private ipv4.
test with remote group on ipv4, you have to use their public IPv4 (can’t use private ipv4).
 
How to determine someone is local or remote? Check whether someone is online. If he is, then use his public ip.
 */

- (void) onChecked:(AMCheckBoxView *)sender
{
    //If the user defined checkbox, you must make sure the ip is valid
    if ([sender isEqual:_userDefinedCheck]) {
        NSString* userIP = _userDefinedTF.stringValue;
        if (![AMCommonTools isValidIpv4:userIP] &&
            ![AMCommonTools isValidIpv6:userIP]) {
            sender.checked = !sender.checked;
            return;
        }
        for (AMUserListItem* userItem in self.userList) {
            userItem.checkbox.checked = NO;
        }
        NSString *command = [self.delegate formatCommand:userIP];
                
        [self.pingCommand stop];
        self.pingCommand.command = command;
        [self.pingCommand run];
        
        return;
    }
    
    if (sender.checked == NO) {
        sender.checked = YES;
    }
    for (AMUserListItem* userItem in self.userList) {
        if([userItem.checkbox isEqual:sender]){
            NSString* ip;
            if([_delegate useIPV6] && userItem.user.ipv6Address){
                ip = userItem.user.ipv6Address;
            }else{// below is ipv4
                if ([userItem.user isOnline] && userItem.user.publicIp){
                    ip= userItem.user.publicIp;
                }else{
                    ip= userItem.user.privateIp;
                }
            }
            NSString *command = [self.delegate formatCommand:ip];
            
            [self.pingCommand stop];
            self.pingCommand.command = command;
            [self.pingCommand run];
        }else{
            userItem.checkbox.checked = NO;
        }
    }
    
    _userDefinedCheck.checked = NO;
}

-(void)executeCommand : (NSString*) command
{
    [self.pingCommand stop];
    self.pingCommand.command = command;
    [self.pingCommand run];
}

@end


@implementation AMPingTabVC

- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
         //
        
    }
    return self;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    userList = [[AMUserList alloc] init:self.tableView
                inputField:_inputField];
    userList.delegate = self;
    self.useIPV6Check.title = @"USE IPV6";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    userList.pingCommand.contentView = self.pingContentView;
    [userList userGroupsChangedPing:nil];
}

- (BOOL) useIPV6
{
    return self.useIPV6Check.checked;
}


-(NSString*) formatCommand:(NSString*) ip
{
    NSString* command;
    
    if ([AMCommonTools isValidIpv4:ip]){
        command = [NSString stringWithFormat:@"ping -c 5 %@", ip];
    }else{
        command = [NSString stringWithFormat:@"ping6 -c 5 %@", ip];
    }

    return command;
}


- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    
}




@end
