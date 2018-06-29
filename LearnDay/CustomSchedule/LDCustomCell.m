//
//  LDCustomCell.m
//  LearnDay
//
//  Created by ipad_kid on 10/24/17.
//  Copyright © 2017 BlackJacket. All rights reserved.
//

#import "LDCustomCell.h"

@implementation LDCustomCell

- (IBAction)editingDidEnd {
    [self.delegateController updateCell:self.row withText:self.classNameField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (self.delegateController.classesDays[textField.text]) {
        return NO;
    }
    
    [textField resignFirstResponder];
    return YES;
}

@end
