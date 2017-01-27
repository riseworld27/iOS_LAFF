//
//  FFScreeningScheduleCell.h
//  laff
//
//  Created by matata on 30.04.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Screening.h"

extern NSString * const FFScreeningScheduleCellIdentifier;
extern CGFloat const FFScreeningScheduleCellHeight;

@interface FFScreeningScheduleCell : UITableViewCell

- (void)updateWithScreening:(Screening *)screening;

@end
