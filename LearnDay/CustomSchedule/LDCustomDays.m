//
//  LDCustomDays.m
//  LearnDay
//
//  Created by ipad_kid on 10/24/17.
//  Copyright © 2017 BlackJacket. All rights reserved.
//

#import "LDCustomDays.h"
#import "LDSharedManager.h"

@implementation LDCustomDays {
    LDSharedManager *_sharedManager;
    BOOL _darkmode;
    NSString *_cellReuseIdentifier;
    NSArray<NSString *> *_weekdayStrings;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _cellReuseIdentifier = @"Cell";
    [self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:_cellReuseIdentifier];
    _sharedManager = LDSharedManager.global;
    _darkmode = [_sharedManager.userDefaults boolForKey:_sharedManager.darkMode];
    _weekdayStrings = NSDateFormatter.new.weekdaySymbols;
    self.tableView.tableFooterView = UIView.new;
    self.tableView.backgroundColor = _darkmode ? _sharedManager.darkBack : _sharedManager.lighBack;
    self.tableView.separatorColor = _darkmode ? _sharedManager.darkSeparator : _sharedManager.lightSeparator;
    self.navigationItem.title = @"Closed Days";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:_cellReuseIdentifier];
    NSInteger indexRow = indexPath.row;
    
    cell.backgroundColor = UIColor.clearColor;
    cell.textLabel.text = _weekdayStrings[indexRow + 1];
    cell.textLabel.textColor = _darkmode ? _sharedManager.lightText : _sharedManager.darkText;
    cell.textLabel.highlightedTextColor = _darkmode ? _sharedManager.darkText : _sharedManager.darkText;
    cell.accessoryType = [self.delegateArray containsObject:@(indexRow + 2)] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    switch (cell.accessoryType) {
        case UITableViewCellAccessoryNone:
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [self.delegateArray
             addObject:[NSNumber numberWithInteger:indexPath.row + 2]];
            break;
            
        case UITableViewCellAccessoryCheckmark:
            cell.accessoryType = UITableViewCellAccessoryNone;
            [self.delegateArray
             removeObject:[NSNumber numberWithInteger:indexPath.row + 2]];
            break;
            
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

@end
