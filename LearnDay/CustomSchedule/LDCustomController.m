//
//  LDCustomController.m
//  LearnDay
//
//  Created by ipad_kid on 10/23/17.
//  Copyright © 2017 BlackJacket. All rights reserved.
//

#import "LDCustomController.h"
#import "LDCustomCell.h"
#import "LDCustomDays.h"
#import "LDSharedManager.h"

@implementation LDCustomController {
    LDSharedManager *sharedManager;
    NSUserDefaults *userDefaults;
    NSMutableArray<NSString *> *classKeys;
    BOOL darkmode;
}

- (IBAction)doneButton {
    [userDefaults setObject:self.classesDays
                     forKey:sharedManager.customSchoolKey];
    [userDefaults synchronize];
    [sharedManager.mainVC updateCoreArray];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    sharedManager = LDSharedManager.global;
    userDefaults = sharedManager.userDefaults;
    darkmode = [userDefaults boolForKey:sharedManager.darkMode];

    NSDictionary *diskPrefs =
        [userDefaults dictionaryForKey:sharedManager.customSchoolKey];
    NSMutableDictionary *typedPrefs = NSMutableDictionary.new;
    for (NSString *key in diskPrefs)
        [typedPrefs setObject:[NSMutableArray arrayWithArray:diskPrefs[key]]
                       forKey:key];
    self.classesDays = typedPrefs;
    classKeys = [NSMutableArray arrayWithArray:self.classesDays.allKeys];
    self.navigationController.navigationBar.barStyle = darkmode;
    self.tableView.backgroundColor =
        darkmode ? sharedManager.darkBack : sharedManager.lighBack;
    self.tableView.separatorColor =
        darkmode ? sharedManager.darkSeparator : sharedManager.lightSeparator;
    self.tableView.tableFooterView = UIView.new;
}

- (IBAction)addRowButton {
    NSNumber *count = [NSNumber numberWithUnsignedInteger:classKeys.count];
    NSString *newKey =
        [@"New Class " stringByAppendingString:count.stringValue];
    [self.classesDays setObject:NSMutableArray.new forKey:newKey];
    [classKeys addObject:newKey];
    [self.tableView reloadData];
}

- (LDCustomCell *)tableView:(UITableView *)tableView
      cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LDCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.row = indexPath.row;
    cell.delegateController = self;
    cell.classNameField.text = classKeys[indexPath.row];
    cell.classNameField.textColor =
        darkmode ? sharedManager.lightText : sharedManager.darkText;
    cell.classNameField.keyboardAppearance =
        darkmode ? UIKeyboardAppearanceDark : UIKeyboardAppearanceLight;
    return cell;
}

- (void)tableView:(UITableView *)tableView
    accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    LDCustomDays *daysController = LDCustomDays.new;
    daysController.delegateArray = self.classesDays[classKeys[indexPath.row]];
    [self.navigationController pushViewController:daysController animated:YES];
}

- (void)updateCell:(NSInteger)cell withText:(NSString *)text {
    NSString *oldKey = classKeys[cell];
    NSMutableArray *holding = self.classesDays[oldKey];
    if (holding == nil)
        NSLog(@"holding was nil");

    [self.classesDays removeObjectForKey:oldKey];
    if (holding == nil)
        NSLog(@"Appears to have been released");
    [self.classesDays setObject:holding forKey:text];

    [classKeys setObject:text
        atIndexedSubscript:[classKeys indexOfObject:oldKey]];
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView
                  editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [NSArray
        arrayWithObject:
            [UITableViewRowAction
                rowActionWithStyle:UITableViewRowActionStyleDestructive
                             title:@"Remove"
                           handler:^(UITableViewRowAction *_Nonnull action,
                                     NSIndexPath *_Nonnull indexPath) {
                               [self.classesDays
                                   removeObjectForKey:classKeys[indexPath.row]];
                               NSArray *deleteRow = [NSArray
                                   arrayWithObject:[NSIndexPath
                                                       indexPathForRow:indexPath
                                                                           .row
                                                             inSection:0]];
                               [self.tableView
                                   deleteRowsAtIndexPaths:deleteRow
                                         withRowAnimation:
                                             UITableViewRowAnimationTop];
                               [classKeys removeObjectAtIndex:indexPath.row];
                           }]];
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
    return self.classesDays.count;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

@end
