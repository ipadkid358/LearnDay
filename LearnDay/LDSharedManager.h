//
//  LDSharedManager.h
//  LearnDay
//
//  Created by ipad_kid on 10/12/17.
//  Copyright © 2017 BlackJacket. All rights reserved.
//

#import "LDViewController.h"
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

@interface LDSharedManager : NSObject

// string keys to NSUserDefaults
@property (nonatomic, readonly) NSString *notifMin;
@property (nonatomic, readonly) NSString *notifHour;
@property (nonatomic, readonly) NSString *visibleSections;
@property (nonatomic, readonly) NSString *darkMode;
@property (nonatomic, readonly) NSString *selectedSchool;
@property (nonatomic, readonly) NSString *customSchoolKey;
@property (nonatomic, readonly) NSString *usingCustomKey;
@property (nonatomic, readonly) NSString *classDetailType;

@property (nonatomic, readonly) NSString *darkmodeToggle;
@property (nonatomic, readonly) NSUserDefaults *userDefaults;

// colors used across all UITableViews
@property (nonatomic, readonly) UIColor *darkBack;
@property (nonatomic, readonly) UIColor *lighBack;
@property (nonatomic, readonly) UIColor *darkText;
@property (nonatomic, readonly) UIColor *lightText;
@property (nonatomic, readonly) UIColor *darkSeparator;
@property (nonatomic, readonly) UIColor *lightSeparator;

@property (nonatomic, strong) LDViewController *mainVC;
@property (nonatomic, copy) NSDateComponents *dateComponents;

+ (instancetype)global;

// NSUserDefaults key for settings persistance
- (NSString *)keyForNotifsWeekday:(NSInteger)weekday;

- (void)setDarkmode:(BOOL)on pop:(BOOL)pop;

// UserNotifications identifier for a weekday
- (NSString *)notifRequestIdentifier:(NSInteger)weekday;
- (void)removeNotifForWeekday:(NSInteger)weekday;

@end
