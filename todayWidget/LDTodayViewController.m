//
//  LDTodayViewController.m
//  todayWidget
//
//  Created by ipad_kid on 10/29/17.
//  Copyright © 2017 BlackJacket. All rights reserved.
//

#import "LDTodayViewController.h"
#import "LDSharedManager.h"

@implementation LDTodayViewController {
    NSString *cellReuseIdentifier;
    NSMutableArray<NSString *> *closedClasses;
    NSInteger closedCount;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    cellReuseIdentifier = @"Cell";
    LDSharedManager *sharedManager = LDSharedManager.global;
    UITableView *tableView = self.tableView;
    [tableView registerClass:UITableViewCell.class
        forCellReuseIdentifier:cellReuseIdentifier];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.allowsSelection = NO;
    NSUserDefaults *userDefaults = sharedManager.userDefaults;
    NSInteger weekday =
        [[NSCalendar.currentCalendar components:NSCalendarUnitWeekday
                                       fromDate:NSDate.date] weekday];
    if (weekday == 1 || weekday == 7)
        closedClasses = [NSMutableArray arrayWithObject:@"Enjoy the weekend!"];
    else {
        NSString *selectedSchoolsKey =
            [userDefaults boolForKey:sharedManager.usingCustomKey]
                ? sharedManager.customSchoolKey
                : sharedManager.selectedSchool;
        NSDictionary<NSString *, NSArray<NSNumber *> *> *schoolSet =
            [userDefaults dictionaryForKey:selectedSchoolsKey];
        if (!schoolSet)
            closedClasses = [NSMutableArray
                arrayWithObject:@"Please launch app to select school"];
        else {
            closedClasses = NSMutableArray.new;
            NSNumber *weekdayObject = [NSNumber numberWithInteger:weekday];

            for (NSString *classStat in schoolSet.allKeys)
                if ([schoolSet[classStat] containsObject:weekdayObject])
                    [closedClasses addObject:classStat];
            if (!closedClasses.count)
                closedClasses =
                    [NSMutableArray arrayWithObject:@"No closed classes today"];
        }
    }
    closedCount = closedClasses.count;
    self.extensionContext.widgetLargestAvailableDisplayMode =
        (closedCount > 2) ? NCWidgetDisplayModeExpanded
                          : NCWidgetDisplayModeCompact;
    [self setContentSize];
}

- (void)setContentSize {
    CGSize maxSize = CGSizeZero;
    maxSize.height = [self.tableView numberOfRowsInSection:0] * 44;
    [UIViewPropertyAnimator
        runningPropertyAnimatorWithDuration:0.1
                                      delay:0
                                    options:UIViewAnimationOptionCurveLinear
                                 animations:^{
                                     self.preferredContentSize = maxSize;
                                 }
                                 completion:nil];
}

- (void)widgetActiveDisplayModeDidChange:(NCWidgetDisplayMode)activeDisplayMode
                         withMaximumSize:(CGSize)maxSize {
    [self.tableView reloadData];
    [self setContentSize];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier];
    cell.textLabel.text = closedClasses[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
    return (self.extensionContext.widgetActiveDisplayMode ==
                NCWidgetDisplayModeCompact &&
            closedCount > 2)
               ? 2
               : closedCount;
}

@end
