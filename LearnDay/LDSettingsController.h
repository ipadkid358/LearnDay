//
//  LDSettingsController.h
//  LearnDay
//
//  Created by ipad_kid on 10/11/17.
//  Copyright © 2017 BlackJacket. All rights reserved.
//

#import "LDSchoolController.h"
#import "LDViewController.h"
#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>

@interface LDSettingsController : UITableViewController <MFMailComposeViewControllerDelegate>

// picker for visible classes, sets LDSelectedLearns
@property (weak, nonatomic) IBOutlet UISegmentedControl *sectionVisibleControl;
@property (weak, nonatomic) IBOutlet UISwitch *notifsSwitch;
// each of the five UITableViewCells days of the week for notifications
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray<UITableViewCell *> *dayCells;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePickerControl;
@property (weak, nonatomic) IBOutlet UISwitch *darkModeSwitch;
// labels added in Storyboard, used to change text color
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray<UILabel *> *builderCellLabels;
@property (weak, nonatomic) IBOutlet UITableViewCell *reportBugCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *shareCustomCell;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray<UIView *> *hardColoredCells;
@property (weak, nonatomic) IBOutlet UISegmentedControl *classDetailControl;
@property (weak, nonatomic) IBOutlet UIView *notifsCellView;

@end
