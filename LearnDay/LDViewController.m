//
//  LDViewController.m
//  LearnDay
//
//  Created by ipad_kid on 10/10/17.
//  Copyright © 2017 BlackJacket. All rights reserved.
//

#import "LDViewController.h"
#import "LDSharedManager.h"

@implementation LDViewController {
    NSArray<NSString *> *_closedClasses;
    NSArray<NSString *> *_openClasses;
    NSArray<NSString *> *_weekdayStrings;
    NSString *_todayString;
    NSUInteger _currentWeekday;
    NSUserDefaults *_userDefaults;
    NSString *_headerFooterID;
    LDSharedManager *_sharedManager;
    BOOL _darkmode;
    BOOL _hideOneRows;
    BOOL _hideTwoRows;
    UIAlertController *_daysInfoAlert;
}

- (void)setColors {
    _darkmode = [_userDefaults boolForKey:_sharedManager.darkMode];
    self.navigationController.navigationBar.barStyle = _darkmode;
    self.tableView.backgroundColor = _darkmode ? _sharedManager.darkBack : _sharedManager.lighBack;
    self.tableView.separatorColor = _darkmode ? _sharedManager.darkSeparator : _sharedManager.lightSeparator;
    [self.tableView reloadData];
}

- (void)updateSelectedLearns {
    self.selectedLearns = [_userDefaults integerForKey:_sharedManager.visibleSections];
    _hideOneRows = NO;
    _hideTwoRows = NO;
    [self.tableView reloadData];
}

- (IBAction)setDayButton:(UIBarButtonItem *)sender {
    UIAlertController *setDayAlert =
    [UIAlertController alertControllerWithTitle:@"Pick Weekday" message:NULL preferredStyle:0];
    for (NSUInteger weekday = 2; weekday < 7; weekday++)
        if (weekday != _currentWeekday) {
            [setDayAlert addAction:[UIAlertAction actionWithTitle:_weekdayStrings[weekday - 1] style:0 handler:^(UIAlertAction *_Nonnull action) {
                [self updateForWeekday:weekday];
            }]];
        }
    
    [setDayAlert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    setDayAlert.view.backgroundColor = UIColor.clearColor;
    setDayAlert.popoverPresentationController.barButtonItem = self.navigationItem.leftBarButtonItem;
    BOOL isPhone = (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone);
    setDayAlert.view.hidden = isPhone;
    setDayAlert.popoverPresentationController.backgroundColor = UIColor.clearColor;
    [self presentViewController:setDayAlert animated:NO completion:^{
        if (_darkmode) {
            UIColor *darkColor = [UIColor colorWithWhite:0.1 alpha:1];
            NSArray<UIView *> *topViewSet = setDayAlert.view.subviews.firstObject.subviews;
            UIView *holdingView = topViewSet.lastObject.subviews.lastObject.subviews.firstObject;
            holdingView.subviews.firstObject.subviews.firstObject.subviews.firstObject.subviews.lastObject.backgroundColor = darkColor;
            topViewSet.firstObject.subviews.lastObject.backgroundColor = darkColor;
        }
        
        if (isPhone) {
            CGRect originalBounds = setDayAlert.view.bounds;
            CGRect tmpBounds = originalBounds;
            tmpBounds.origin.y = -self.view.bounds.size.height;
            setDayAlert.view.bounds = tmpBounds;
            setDayAlert.view.hidden = NO;
            [UIViewPropertyAnimator runningPropertyAnimatorWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
                setDayAlert.view.bounds = originalBounds;
            } completion:nil];
        }
    }];
}

- (void)updateForWeekday:(NSUInteger)weekday {
    [self setClassesForWeekday:weekday];
    [self.tableView reloadData];
    self.navigationItem.title = _todayString;
    _hideOneRows = NO;
    _hideTwoRows = NO;
    _currentWeekday = weekday;
}

- (void)setClassesForWeekday:(NSInteger)weekday {
    if (weekday == 1 || weekday == 7) {
        _todayString = @"Weekend";
        _openClasses = @[];
        _closedClasses = @[];
        return;
    }
    
    NSMutableArray<NSString *> *tmpOpen = NSMutableArray.new;
    NSMutableArray<NSString *> *tmpClosed = NSMutableArray.new;
    NSNumber *weekdayObject = [NSNumber numberWithInteger:weekday];
    for (NSString *classStat in self.schoolSet)
        [[self.schoolSet[classStat] containsObject:weekdayObject]
         ? tmpClosed
         : tmpOpen addObject:classStat];
    _todayString = _weekdayStrings[weekday - 1];
    _openClasses = tmpOpen;
    _closedClasses = tmpClosed;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _sharedManager = LDSharedManager.global;
    _weekdayStrings = NSDateFormatter.new.weekdaySymbols;
    _userDefaults = _sharedManager.userDefaults;
    _darkmode = [_userDefaults boolForKey:_sharedManager.darkMode];
    [self setColors];
    _sharedManager.mainVC = self;
    self.navigationItem.leftBarButtonItem.style = UIBarButtonItemStylePlain;
    self.navigationItem.rightBarButtonItem.style = UIBarButtonItemStylePlain;
    self.tableView.tableFooterView = UIView.new;
    self.cellDetailType =
    [_userDefaults integerForKey:_sharedManager.classDetailType];
    [self updateSelectedLearns];
    NSString *showedSchool = @"showedSchool";
    if (![_userDefaults boolForKey:showedSchool]) {
        [self presentViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"ModalSchools"] animated:YES completion:nil];
        [_userDefaults setBool:YES forKey:showedSchool];
    }
    
    NSString *selectedSchoolsKey = [_userDefaults boolForKey:_sharedManager.usingCustomKey] ? _sharedManager.customSchoolKey : _sharedManager.selectedSchool;
    self.schoolSet = [_userDefaults dictionaryForKey:selectedSchoolsKey];
    NSDateComponents *weekdays = [NSCalendar.currentCalendar components:NSCalendarUnitWeekday fromDate:NSDate.date];
    [self updateForWeekday:weekdays.weekday];
    
    _headerFooterID = @"headerFooter";
    [self.tableView registerClass:UITableViewHeaderFooterView.class forHeaderFooterViewReuseIdentifier:_headerFooterID];
}

- (void)fixHeightsInSection:(NSInteger)section close:(BOOL)close {
    NSMutableArray<NSIndexPath *> *indexPaths = NSMutableArray.new;
    NSInteger rows = [self tableView:self.tableView numberOfRowsInSection:section];
    for (NSInteger indexPath = 0; indexPath < rows; indexPath++)
        [indexPaths addObject:[NSIndexPath indexPathForRow:indexPath inSection:section]];
    UITableViewRowAnimation animation = close ? UITableViewRowAnimationTop : UITableViewRowAnimationBottom;
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:animation];
}

- (void)headerHitOne:(UIGestureRecognizer *)gestureRecognizer {
    _hideOneRows = !_hideOneRows;
    [self fixHeightsInSection:0 close:_hideOneRows];
}

- (void)headerHitTwo:(UIGestureRecognizer *)gestureRecognizer {
    _hideTwoRows = !_hideTwoRows;
    [self fixHeightsInSection:1 close:_hideTwoRows];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return ((indexPath.section && _hideTwoRows) || (!indexPath.section && _hideOneRows)) ? 0 : UITableViewAutomaticDimension;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:_headerFooterID];
    SEL headerRec = section ? @selector(headerHitTwo:) : @selector(headerHitOne:);
    [headerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:headerRec]];
    return headerView;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *openText = @"Open";
    NSString *closedText = @"Closed";
    switch (self.selectedLearns) {
        case LDAllLearns:
            return section ? closedText : openText;
        case LDOpenLearns:
            return openText;
        case LDClosedLearns:
            return closedText;
    }
}

- (void)dismissDaysInfoAlert {
    if (_daysInfoAlert) {
        CGRect newBounds = _daysInfoAlert.view.bounds;
        newBounds.origin.y = self.view.bounds.size.height;
        [UIViewPropertyAnimator runningPropertyAnimatorWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            _daysInfoAlert.view.bounds = newBounds;
        } completion:^(UIViewAnimatingPosition finalPosition) {
            [_daysInfoAlert dismissViewControllerAnimated:NO completion:nil];
            _daysInfoAlert = nil;
        }];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self fixAlertColors];
}

- (void)fixAlertColors {
    if (_darkmode && _daysInfoAlert) {
        UIColor *darkColor = [UIColor colorWithWhite:0.1 alpha:1];
        UIView *topView = _daysInfoAlert.view.subviews.firstObject.subviews.firstObject.subviews.lastObject;
        topView.backgroundColor = darkColor;
        for (UILabel *label in topView.subviews.firstObject.subviews.firstObject.subviews) {
            if ([label respondsToSelector:@selector(setTextColor:)]) {
                label.textColor = _sharedManager.lightText;
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.cellDetailType != 2) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *className = cell.textLabel.text;
        NSString *daysTitle = [NSString stringWithFormat:@"%@\n\n%@ Days", className, self.cellDetailType ? @"Open" : @"Closed"];
        NSMutableString *daysMessage = NSMutableString.new;
        NSArray *weekdaySet;
        if (self.cellDetailType) {
            NSMutableArray<NSNumber *> *allDays = [NSMutableArray arrayWithArray:@[ @2, @3, @4, @5, @6 ]];
            [allDays removeObjectsInArray:self.schoolSet[className]];
            weekdaySet = allDays;
        } else {
            weekdaySet = self.schoolSet[className];
        }
        for (NSNumber *weekday in weekdaySet) {
            int weekdayIndex = weekday.intValue;
            if (weekdayIndex)
                [daysMessage appendFormat:@"\n%@", _weekdayStrings[weekdayIndex - 1]];
        }
        _daysInfoAlert = [UIAlertController alertControllerWithTitle:daysTitle message:[daysMessage substringFromIndex:1] preferredStyle:UIAlertControllerStyleAlert];
        _daysInfoAlert.view.hidden = YES;
        [self presentViewController:_daysInfoAlert animated:NO completion:^{
            [self fixAlertColors];
            [_daysInfoAlert.view.superview.subviews.firstObject
             addGestureRecognizer:
             [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissDaysInfoAlert)]];
            CGRect originalBounds = _daysInfoAlert.view.bounds;
            CGRect tmpBounds = originalBounds;
            tmpBounds.origin.y = -self.view.frame.size.height;
            _daysInfoAlert.view.bounds = tmpBounds;
            _daysInfoAlert.view.hidden = NO;
            [UIViewPropertyAnimator
             runningPropertyAnimatorWithDuration:0.15
             delay:0
             options:
             UIViewAnimationOptionCurveLinear
             animations:^{
                 _daysInfoAlert.view
                 .bounds =
                 originalBounds;
             }
             completion:nil];
        }];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    BOOL closedSection;
    switch (self.selectedLearns) {
        case LDAllLearns:
            closedSection = indexPath.section;
            break;
            
        case LDOpenLearns:
            closedSection = NO;
            break;
            
        case LDClosedLearns:
            closedSection = YES;
            break;
    }
    
    cell.textLabel.text = (closedSection ? _closedClasses : _openClasses)[indexPath.row];
    cell.textLabel.textColor = _darkmode ? _sharedManager.lightText : _sharedManager.darkText;
    cell.textLabel.highlightedTextColor = _darkmode ? _sharedManager.darkText : _sharedManager.darkText;
    cell.backgroundColor = _darkmode ? _sharedManager.darkBack : _sharedManager.lighBack;
    cell.contentView.backgroundColor = _darkmode ? _sharedManager.darkBack : _sharedManager.lighBack;
    cell.selectionStyle = (self.cellDetailType == 2) ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (self.selectedLearns) {
        case LDAllLearns:
            return (section ? _closedClasses : _openClasses).count;
            
        case LDOpenLearns:
            return _openClasses.count;
            break;
            
        case LDClosedLearns:
            return _closedClasses.count;
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return (self.selectedLearns) ? 1 : 2;
}

- (void)updateCoreArray {
    NSString *selectedSchoolsKey = [_userDefaults boolForKey:_sharedManager.usingCustomKey] ? _sharedManager.customSchoolKey : _sharedManager.selectedSchool;
    self.schoolSet = [_userDefaults dictionaryForKey:selectedSchoolsKey];
    [self updateForWeekday:_currentWeekday];
}

- (void)addNotifsForWeekday:(NSInteger)weekday {
    UNMutableNotificationContent *content = UNMutableNotificationContent.new;
    NSInteger hour = [_userDefaults integerForKey:_sharedManager.notifHour];
    BOOL tomorrow = (hour > 10);
    
    [self setClassesForWeekday:weekday];
    if (_closedClasses.count) {
        content.body = [_closedClasses componentsJoinedByString:@"\n"];
        content.title = [@"Closed Classes " stringByAppendingString:tomorrow ? @"Tomorrow" : @"Today"];
    } else {
        content.body = [@"There are no closed classes on " stringByAppendingString:_todayString];
        content.title = [@"No Closed Classes " stringByAppendingString:tomorrow ? @"Tomorrow" : @"Today"];
    }
    
    NSDateComponents *components = _sharedManager.dateComponents;
    components.weekday = tomorrow ? weekday - 1 : weekday;
    components.hour = hour;
    components.minute = [_userDefaults integerForKey:_sharedManager.notifMin];
    
    UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
    NSString *requestIdentifier = [_sharedManager notifRequestIdentifier:weekday];
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifier content:content trigger:trigger];
    
    [UNUserNotificationCenter.currentNotificationCenter addNotificationRequest:request withCompletionHandler:nil];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

@end
