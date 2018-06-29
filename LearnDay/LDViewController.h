//
//  LDViewController.h
//  LearnDay
//
//  Created by ipad_kid on 10/10/17.
//  Copyright © 2017 BlackJacket. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    LDOpenLearns = (1 << 0),                      // 1
    LDClosedLearns = (1 << 1),                    // 2
    LDAllLearns = (LDOpenLearns & LDClosedLearns) // 0
} LDSelectedLearns;

@interface LDViewController : UITableViewController

@property (nonatomic) LDSelectedLearns selectedLearns;
@property (nonatomic) NSInteger cellDetailType;
// key is class name, array is days closed
@property (nonatomic, strong)  NSDictionary<NSString *, NSArray<NSNumber *> *> *schoolSet;

// add UserNotifications for a weekday
- (void)addNotifsForWeekday:(NSInteger)weekday;

// properly handle UI updates for schoolSet changes
- (void)updateCoreArray;

// update UI to respect darkmode
- (void)setColors;
- (void)updateSelectedLearns;

@end
