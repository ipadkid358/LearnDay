//
//  LDSharedManager.m
//  LearnDay
//
//  Created by ipad_kid on 10/12/17.
//  Copyright © 2017 BlackJacket. All rights reserved.
//

#import "LDSharedManager.h"

@implementation LDSharedManager

+ (instancetype)global {
    static dispatch_once_t dispatchOnce;
    static LDSharedManager *manager = nil;
    
    dispatch_once(&dispatchOnce, ^{
        manager = [LDSharedManager new];
    });
    
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _notifMin = @"notifMin";
        _notifHour = @"notifHour";
        _visibleSections = @"visibleSections";
        _darkMode = @"darkMode";
        _selectedSchool = @"selectedSchool";
        _customSchoolKey = @"customSchoolSet";
        _usingCustomKey = @"usingCustomSchool";
        _classDetailType = @"cellDetailType";
        
        _darkmodeToggle = @"switchdarkmode";
        _userDefaults = [[NSUserDefaults alloc]
                         initWithSuiteName:@"group.com.ipadkid.LearnDay"];
        
        _darkBack = UIColor.blackColor;
        _lighBack = UIColor.whiteColor;
        _darkText = UIColor.blackColor;
        _lightText = UIColor.whiteColor;
        _darkSeparator = UIColor.darkGrayColor;
        _lightSeparator = UIColor.grayColor;
        _dateComponents = [NSCalendar.currentCalendar components:(NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute)
                                                        fromDate:NSDate.new];
    }
    
    return self;
}

- (void)setDarkmode:(BOOL)on pop:(BOOL)pop {
#ifndef TODAY_EXTENSION
    NSUserDefaults *userDefaults = self.userDefaults;
    [userDefaults setBool:on forKey:self.darkMode];
    [userDefaults synchronize];
    
    NSString *mainTitle = [on ? @"Default" : @"Dark" stringByAppendingString:@" Mode"];
    NSString *subtitle = [@"Launch with dark mode " stringByAppendingString:on ? @"disabled" : @"enabled"];
    UIApplicationShortcutIcon *icon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"darkmodeToggle"];
    UIApplicationShortcutItem *darkmodeShortcut = [[UIApplicationShortcutItem alloc] initWithType:self.darkmodeToggle localizedTitle:mainTitle localizedSubtitle:subtitle icon:icon userInfo:NULL];
    UIApplication.sharedApplication.shortcutItems = @[darkmodeShortcut];
    [self.mainVC setColors];
    if (pop) {
        [self.mainVC.navigationController popToRootViewControllerAnimated:NO];
    }
#endif
}

- (NSString *)keyForNotifsWeekday:(NSInteger)weekday {
    return [@"notifsFor" stringByAppendingString:[[NSNumber numberWithInteger:weekday] stringValue]];
}

- (NSString *)notifRequestIdentifier:(NSInteger)weekday {
    return [@"com.ipadkid.LearnDay.weekday" stringByAppendingString:[[NSNumber numberWithInteger:weekday] stringValue]];
}

- (void)removeNotifForWeekday:(NSInteger)weekday {
    [UNUserNotificationCenter.currentNotificationCenter removeDeliveredNotificationsWithIdentifiers:@[
                                                                                                      [self notifRequestIdentifier:weekday]
                                                                                                      ]];
}

@end
