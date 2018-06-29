//
//  LDCustomController.h
//  LearnDay
//
//  Created by ipad_kid on 10/23/17.
//  Copyright © 2017 BlackJacket. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LDCustomController : UITableViewController

@property (strong, nonatomic) NSMutableDictionary<NSString *, NSMutableArray<NSNumber *> *> *classesDays;

- (void)updateCell:(NSInteger)cell withText:(NSString *)text;

@end
