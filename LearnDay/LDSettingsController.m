//
//  LDSettingsController.m
//  LearnDay
//
//  Created by ipad_kid on 10/11/17.
//  Copyright © 2017 BlackJacket. All rights reserved.
//

#import "LDSettingsController.h"
#import "LDViewController.h"

@implementation LDSettingsController {
    NSUserDefaults *_userDefaults;
    LDViewController *_mainVC;
    LDSharedManager *_sharedManager;
    NSString *_notifsSwitchKey;
    UNUserNotificationCenter *_notifsCenter;
    NSString *_headerFooterID;
    BOOL _darkmode;
    UIAlertController *_cellInfoAlert;
}

- (void)setColors {
    self.tableView.backgroundColor = _darkmode ? _sharedManager.darkBack : _sharedManager.lighBack;
    self.tableView.separatorColor = _darkmode ? _sharedManager.darkSeparator : _sharedManager.lightSeparator;
    for (UIView *cellBackground in self.hardColoredCells) {
        cellBackground.backgroundColor = _darkmode ? _sharedManager.darkBack : _sharedManager.lighBack;
    }
    for (UITableViewCell *cell in self.dayCells) {
        cell.textLabel.textColor = _darkmode ? _sharedManager.lightText : _sharedManager.darkText;
        cell.textLabel.highlightedTextColor = _darkmode ? _sharedManager.darkText : _sharedManager.darkText;
    }
    [self.datePickerControl setValue:_darkmode ? _sharedManager.lightText : _sharedManager.darkText forKey:@"textColor"];
    for (UILabel *cellLabel in self.builderCellLabels) {
        cellLabel.textColor = _darkmode ? _sharedManager.lightText : _sharedManager.darkText;
    }
    
    self.reportBugCell.textLabel.textColor = _darkmode ? _sharedManager.lightText : _sharedManager.darkText;
    self.reportBugCell.textLabel.highlightedTextColor = _darkmode ? _sharedManager.darkText : _sharedManager.darkText;
    self.shareCustomCell.textLabel.textColor = _darkmode ? _sharedManager.lightText : _sharedManager.darkText;
    self.shareCustomCell.detailTextLabel.textColor = _darkmode ? _sharedManager.lightText : _sharedManager.darkText;
    self.shareCustomCell.textLabel.highlightedTextColor = _darkmode ? _sharedManager.darkText : _sharedManager.darkText;
    self.shareCustomCell.detailTextLabel.highlightedTextColor = _darkmode ? _sharedManager.darkText : _sharedManager.darkText;
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _sharedManager = LDSharedManager.global;
    _userDefaults = _sharedManager.userDefaults;
    _mainVC = _sharedManager.mainVC;
    _notifsSwitchKey = @"notifsSwitch";
    _notifsCenter = UNUserNotificationCenter.currentNotificationCenter;
    _darkmode = [_userDefaults boolForKey:_sharedManager.darkMode];
    
    self.navigationItem.title = @"Settings";
    self.tableView.tableFooterView = UIView.new;
    self.sectionVisibleControl.selectedSegmentIndex =
    [_userDefaults integerForKey:_sharedManager.visibleSections];
    self.notifsSwitch.on = [_userDefaults boolForKey:_notifsSwitchKey];
    self.darkModeSwitch.on = _darkmode;
    self.classDetailControl.selectedSegmentIndex = [_userDefaults integerForKey:_sharedManager.classDetailType];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Pick School" style:UIBarButtonItemStylePlain target:self action:@selector(presentSchoolPicker)];
    [self setColors];
    NSArray<NSString *> *weekdayStrings = NSDateFormatter.new.weekdaySymbols;
    for (unsigned char weekday = 2; weekday < 7; weekday++) {
        UITableViewCell *cell = self.dayCells[weekday - 2];
        cell.textLabel.text = weekdayStrings[weekday - 1];
        BOOL checked = [_userDefaults boolForKey:[_sharedManager keyForNotifsWeekday:weekday]];
        cell.accessoryType = checked ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    
    NSString *isVisitKey = @"isVisit";
    if ([_userDefaults boolForKey:isVisitKey]) {
        [_notifsCenter getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings *_Nonnull settings) {
            if (settings.alertSetting != UNNotificationSettingEnabled) {
                [_userDefaults setBool:NO forKey:_notifsSwitchKey];
                [self.notifsCellView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showBadNotifsPermsAlert)]];
                NSMutableArray<NSIndexPath *> *indexPaths = NSMutableArray.new;
                for (NSInteger indexPath = 1; indexPath < 7; indexPath++)
                    [indexPaths addObject:[NSIndexPath indexPathForRow:indexPath inSection:1]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.notifsSwitch.enabled = NO;
                    self.notifsSwitch.on = NO;
                    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
                });
            }
        }];
    } else {
        [_userDefaults setInteger:9 forKey:_sharedManager.notifHour];
        [_userDefaults setInteger:30 forKey:_sharedManager.notifMin];
        [UNUserNotificationCenter.currentNotificationCenter
         requestAuthorizationWithOptions:UNAuthorizationOptionAlert
         completionHandler:^(BOOL granted, NSError *_Nullable error) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 self.notifsSwitch.enabled = granted;
             });
         }];
        [_userDefaults setBool:YES forKey:isVisitKey];
    }
    [_userDefaults synchronize];
    
    for (UIView *subview in self.datePickerControl.subviews.firstObject.subviews)
        if (subview.frame.size.height <= 2.5) {
            subview.layer.opacity = 0;
        }
    NSDateComponents *dateComp = _sharedManager.dateComponents;
    dateComp.hour = [_userDefaults integerForKey:_sharedManager.notifHour];
    dateComp.minute = [_userDefaults integerForKey:_sharedManager.notifMin];
    self.datePickerControl.date = [NSCalendar.currentCalendar dateFromComponents:dateComp];
    
    _headerFooterID = @"headerFooter";
    [self.tableView registerClass:UITableViewHeaderFooterView.class forHeaderFooterViewReuseIdentifier:_headerFooterID];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [tableView dequeueReusableHeaderFooterViewWithIdentifier:_headerFooterID];
}

- (IBAction)sectionShowControl {
    LDSelectedLearns pickedLearns = self.sectionVisibleControl.selectedSegmentIndex;
    [_userDefaults setInteger:pickedLearns forKey:_sharedManager.visibleSections];
    [_userDefaults synchronize];
    
    [_mainVC updateSelectedLearns];
}

- (IBAction)classDetailChange:(UISegmentedControl *)sender {
    [_userDefaults setInteger:sender.selectedSegmentIndex forKey:_sharedManager.classDetailType];
    [_userDefaults synchronize];
    _sharedManager.mainVC.cellDetailType = sender.selectedSegmentIndex;
    [_sharedManager.mainVC.tableView reloadData];
}

- (IBAction)notifsSwitched {
    BOOL notifsOn = self.notifsSwitch.isOn;
    [_userDefaults setBool:notifsOn forKey:_notifsSwitchKey];
    
    NSMutableArray<NSIndexPath *> *indexPaths = NSMutableArray.new;
    [indexPaths addObject:[NSIndexPath indexPathForRow:1 inSection:1]];
    for (NSInteger indexPath = 2; indexPath < 7; indexPath++) {
        [indexPaths addObject:[NSIndexPath indexPathForRow:indexPath inSection:1]];
        if (notifsOn) {
            if ([_userDefaults boolForKey:[_sharedManager keyForNotifsWeekday:indexPath]]) {
                [_mainVC addNotifsForWeekday:indexPath];
            }
        } else {
            [_sharedManager removeNotifForWeekday:indexPath];
        }
    }
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
    [_userDefaults synchronize];
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return (indexPath.section == 1 && indexPath.row && !self.notifsSwitch.isOn)
    ? 0
    : UITableViewAutomaticDimension;
}

- (void)dismissDaysInfoAlert {
    if (_cellInfoAlert) {
        CGRect newBounds = _cellInfoAlert.view.bounds;
        newBounds.origin.y = self.view.bounds.size.height;
        [UIViewPropertyAnimator runningPropertyAnimatorWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
            _cellInfoAlert.view.bounds = newBounds;
        } completion:^(UIViewAnimatingPosition finalPosition) {
            [_cellInfoAlert dismissViewControllerAnimated:NO completion:nil];
            _cellInfoAlert = nil;
        }];
    }
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [self fixAlertColors];
}

- (void)fixAlertColors {
    if (_darkmode && _cellInfoAlert) {
        UIColor *darkColor = [UIColor colorWithWhite:0.1 alpha:1];
        UIView *topView = _cellInfoAlert.view.subviews.firstObject.subviews
        .firstObject.subviews.lastObject;
        topView.backgroundColor = darkColor;
        for (UILabel *label in topView.subviews.firstObject.subviews.firstObject.subviews) {
            if ([label respondsToSelector:@selector(setTextColor:)]) {
                label.textColor = _sharedManager.lightText;
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSString *alertTitle;
    NSString *alertMessage;
    if (indexPath.section) {
        alertTitle = @"Notifications";
        alertMessage = @"Notifications are sent at a specified time with a list of closed classes.\n"
        "Times after 10:59 AM will send the next day's class set";
    } else {
        switch (indexPath.row) {
            case 0:
                alertTitle = @"Sections";
                alertMessage = @"The visible sections on the main screen can either be open, closed, or both can be shown";
                break;
                
            case 1:
                alertTitle = @"Dark Theme";
                alertMessage = @"Enabling dark theme turns all app elements a darker color, and is generally easier on the eyes";
                break;
                
            case 2:
                alertTitle = @"Class Detail";
                alertMessage = @"Class details are shown when clicking on a class in the main view. "
                "The pop-up can show when the class is open, closed, or the pop-up can be fully disabled";
                break;
                
            default:
                break;
        }
    }
    _cellInfoAlert = [UIAlertController
                      alertControllerWithTitle:alertTitle
                      message:alertMessage
                      preferredStyle:UIAlertControllerStyleAlert];
    _cellInfoAlert.view.hidden = YES;
    [self
     presentViewController:_cellInfoAlert
     animated:NO
     completion:^{
         [self fixAlertColors];
         [_cellInfoAlert.view.superview.subviews.firstObject
          addGestureRecognizer:
          [[UITapGestureRecognizer alloc]
           initWithTarget:self
           action:@selector
           (dismissDaysInfoAlert)]];
         CGRect originalBounds = _cellInfoAlert.view.bounds;
         CGRect tmpBounds = originalBounds;
         tmpBounds.origin.y = -self.view.frame.size.height;
         _cellInfoAlert.view.bounds = tmpBounds;
         _cellInfoAlert.view.hidden = NO;
         [UIViewPropertyAnimator
          runningPropertyAnimatorWithDuration:0.15
          delay:0
          options:
          UIViewAnimationOptionCurveLinear
          animations:^{
              _cellInfoAlert.view
              .bounds =
              originalBounds;
          }
          completion:nil];
     }];
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Notification section, not switch or picker
    if (indexPath.section == 1 && indexPath.row > 1 && self.notifsSwitch.isOn) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSInteger weekday = indexPath.row;
        NSString *keyForCell = [_sharedManager keyForNotifsWeekday:weekday];
        
        switch (cell.accessoryType) {
            case UITableViewCellAccessoryNone:
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [_userDefaults setBool:YES forKey:keyForCell];
                [_mainVC addNotifsForWeekday:weekday];
                break;
                
            case UITableViewCellAccessoryCheckmark:
                cell.accessoryType = UITableViewCellAccessoryNone;
                [_userDefaults setBool:NO forKey:keyForCell];
                [_sharedManager removeNotifForWeekday:weekday];
                break;
                
            default:
                break;
        }
        
        [_userDefaults synchronize];
    } else if (indexPath.section == 2) {
        if (MFMailComposeViewController.canSendMail) {
            MFMailComposeViewController *mailController = MFMailComposeViewController.new;
            mailController.toRecipients = @[@"ipadkid358@gmail.com"];
            mailController.mailComposeDelegate = self;
            
            if (indexPath.row) { // share custom school
                NSDictionary *customSchoolDict = [_userDefaults dictionaryForKey:_sharedManager.customSchoolKey];
                NSData *binary = [NSPropertyListSerialization dataWithPropertyList:customSchoolDict format:NSPropertyListBinaryFormat_v1_0 options:0 error:NULL];
                [mailController addAttachmentData:binary mimeType:@"application/x-plist" fileName:@"CustomSchool.plist"];
                [mailController setMessageBody:@"School Name:\n\n"
                 "We will contact you if we  have any futher questions\n"
                 "Your custom school schedule has already been added\n" isHTML:NO];
                mailController.subject = @"Class Days Custom Schedule";
            } else {
                [mailController setSubject:@"Class Days Bug Report"];
                UIDevice *device = UIDevice.currentDevice;
                
                NSString *messageBody =
                [@"Bug or Issue: \n\nSome device information and your "
                 @"settings are attached below, please do not remove "
                 @"them.\n"
                 stringByAppendingString:
                 [NSString stringWithFormat:@"%@, %@ %@",
                  device.model,
                  device.systemName,
                  device.systemVersion]];
                [mailController setMessageBody:messageBody isHTML:NO];
                
                NSDictionary *prefsDict = _userDefaults.dictionaryRepresentation;
                NSData *binary = [NSPropertyListSerialization dataWithPropertyList:prefsDict format:NSPropertyListBinaryFormat_v1_0 options:0 error:NULL];
                [mailController addAttachmentData:binary mimeType:@"application/x-plist" fileName:@"ClassDaysPrefs.plist"];
            }
            [self presentViewController:mailController animated:YES completion:nil];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        } else {
            UIAlertController *noEmail = [UIAlertController alertControllerWithTitle:@"No Email" message:@"There is no email setup on this device"   preferredStyle:UIAlertControllerStyleAlert];
            [noEmail addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
            [noEmail addAction:[UIAlertAction  actionWithTitle:@"Contact" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
                [UIApplication.sharedApplication openURL:[NSURL URLWithString:@"http://ipadkid.cf/contact.html"] options:@{} completionHandler:nil];
            }]];
            [self presentViewController:noEmail animated:YES completion:nil];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)presentSchoolPicker {
    [self.navigationController pushViewController:[self.storyboard instantiateViewControllerWithIdentifier:@"Schools"] animated:YES];
}

- (IBAction)datePickerHit {
    NSDateComponents *dateComp = [NSCalendar.currentCalendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:self.datePickerControl.date];
    [_userDefaults setInteger:dateComp.hour forKey:_sharedManager.notifHour];
    [_userDefaults setInteger:dateComp.minute forKey:_sharedManager.notifMin];
    for (NSInteger weekday = 2; weekday < 7; weekday++) {
        if ([_userDefaults boolForKey:[_sharedManager keyForNotifsWeekday:weekday]]) {
            [_mainVC addNotifsForWeekday:weekday];
        }
    }
    [_userDefaults synchronize];
}

- (IBAction)darkmodeSwitched {
    _darkmode = self.darkModeSwitch.isOn;
    [_sharedManager setDarkmode:_darkmode pop:NO];
    [self setColors];
}

- (void)showBadNotifsPermsAlert {
    NSString *alertTitle = @"Enable Notifications";
    NSString *alertMessage = @"Please open Settings and enable notifications for this app";
    UIAlertController *badNotifPerms = [UIAlertController alertControllerWithTitle:alertTitle message:alertMessage preferredStyle:1];
    [badNotifPerms addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
    [badNotifPerms addAction:[UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        [UIApplication.sharedApplication openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:^(BOOL success) {
            if (success) {
                [self.navigationController popViewControllerAnimated:NO];
            }
        }];
    }]];
    [self presentViewController:badNotifPerms animated:YES completion:nil];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

@end
