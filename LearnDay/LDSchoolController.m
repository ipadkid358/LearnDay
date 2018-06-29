//
//  LDSchoolController.m
//  LearnDay
//
//  Created by ipad_kid on 10/11/17.
//  Copyright © 2017 BlackJacket. All rights reserved.
//

#import "LDSchoolController.h"
#import "LDCustomController.h"
#import "LDViewController.h"

@implementation LDSchoolController {
    NSArray<NSDictionary<NSString *, NSString *> *> *_schoolList;
    NSUserDefaults *_userDefaults;
    LDSharedManager *_sharedManager;
    BOOL _darkmode;
    NSUInteger _schoolCount;
    NSString *_checkedSchoolKey;
    NSInteger _checkedRow;
    NSString *_customUSID;
    NSString *_remoteUSID;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _sharedManager = LDSharedManager.global;
    _userDefaults = _sharedManager.userDefaults;
    UITableView *tableView = self.tableView;
    tableView.tableFooterView = UIView.new;
    // see repo root for example plists
    _schoolList = [NSArray arrayWithContentsOfURL:[NSURL URLWithString:@"https://s3.amazonaws.com/learnday/root.plist"]];
    _schoolCount = _schoolList.count;
    _darkmode = [_userDefaults boolForKey:_sharedManager.darkMode];
    self.navigationItem.title = @"Pick School";
    if (self.navigationController.viewControllers.count < 2) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButton)];
        self.navigationController.navigationBar.barStyle = _darkmode;
    }
    tableView.backgroundColor = _darkmode ? _sharedManager.darkBack : _sharedManager.lighBack;
    tableView.separatorColor = _darkmode ? _sharedManager.darkSeparator : _sharedManager.lightSeparator;
    if (!_schoolList) {
        UIAlertController *internetAlert = [UIAlertController alertControllerWithTitle:@"No Internet Connection" message:@"An internet connection is required to fetch new schools' class lists. You can still pick and edit your custom school" preferredStyle:1];
        [internetAlert addAction:[UIAlertAction actionWithTitle:@"Ok" style:1 handler:nil]];
        [self presentViewController:internetAlert animated:YES completion:nil];
    }
    _checkedSchoolKey = @"selectedUSID";
    _customUSID = @"customSchoolUSID";
    _remoteUSID = @"USID";
    NSString *usid = [_userDefaults stringForKey:_checkedSchoolKey];
    if (usid) {
        if ([usid isEqualToString:_customUSID]) {
            _checkedRow = _schoolList.count;
        } else {
            _checkedRow = 0;
            for (NSDictionary *schoolInfo in _schoolList) {
                if ([schoolInfo[_remoteUSID] isEqualToString:usid]) {
                    break;
                }
                _checkedRow++;
            }
        }
    } else {
        _checkedRow = -1;
    }
}

- (void)doneButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    NSInteger index = indexPath.row;
    if (index < _schoolCount) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
        cell.textLabel.text = _schoolList[index][@"SchoolName"];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CustomCell"];
        cell.detailTextLabel.textColor = _darkmode ? _sharedManager.lightText : _sharedManager.darkText;
        cell.detailTextLabel.highlightedTextColor = _darkmode ? _sharedManager.darkText : _sharedManager.darkText;
        [cell.contentView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(presentCustomSchool:)]];
    }
    if (_checkedRow == index) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    cell.textLabel.textColor = _darkmode ? _sharedManager.lightText : _sharedManager.darkText;
    cell.textLabel.highlightedTextColor = _darkmode ? _sharedManager.darkText : _sharedManager.darkText;
    return cell;
}

- (void)presentCustomSchool:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Custom"] animated:YES completion:nil];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger index = indexPath.row;
    if (index < _schoolCount) {
        NSDictionary *schoolInfo = _schoolList[index];
        NSString *selectedSchool = schoolInfo[@"Resource"];
        NSDictionary *schoolClasses = [NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString:selectedSchool]];
        [_userDefaults setObject:schoolClasses forKey:_sharedManager.selectedSchool];
        [_userDefaults setObject:schoolInfo[_remoteUSID] forKey:_checkedSchoolKey];
        [_userDefaults setBool:NO forKey:_sharedManager.usingCustomKey];
    } else {
        [_userDefaults setObject:_customUSID forKey:_checkedSchoolKey];
        [_userDefaults setBool:YES forKey:_sharedManager.usingCustomKey];
    }
    
    UITableViewCell *checkedCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_checkedRow inSection:0]];
    checkedCell.accessoryType = UITableViewCellAccessoryNone;
    checkedCell = [tableView cellForRowAtIndexPath:indexPath];
    checkedCell.accessoryType = UITableViewCellAccessoryCheckmark;
    _checkedRow = index;
    
    [_userDefaults synchronize];
    [_sharedManager.mainVC updateCoreArray];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _schoolCount + 1;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

@end
