//
//  AMClockTabVC.m
//  Artsmesh
//
//  Created by whiskyzed on 4/16/15.
//  Copyright (c) 2015 Artsmesh. All rights reserved.
//

#import "AMClockTabVC.h"
#import "AMClockTabCellVC.h"


@interface AMClockTabVC ()<NSTableViewDataSource, NSTableViewDelegate>
{

}
@property (weak) IBOutlet NSTableView *tableView;

@property   NSMutableArray*  tabCells;
@end

@implementation AMClockTabVC
- (IBAction)addTableCell:(id)sender {
    
    AMClockTabCellVC *vc = [[AMClockTabCellVC alloc]
                                initWithNibName:@"AMClockTabCellVC" bundle:nil];
    [self.tabCells addObject:vc];
    [self.tableView reloadData];
    [self.tableView scrollRowToVisible:self.tabCells.count - 1];
}


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.tabCells.count;
}

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row
{
    return [self.tabCells[row] view];
}




- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    self.tabCells = [[NSMutableArray alloc] init];
}

@end
