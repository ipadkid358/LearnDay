//
//  LDCustomCell.h
//  LearnDay
//
//  Created by ipad_kid on 10/24/17.
//  Copyright © 2017 BlackJacket. All rights reserved.
//

#import "LDCustomController.h"
#import <UIKit/UIKit.h>

@interface LDCustomCell : UITableViewCell <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *classNameField;
@property (nonatomic) NSInteger row;
@property (strong, nonatomic, readwrite) LDCustomController *delegateController;

@end
