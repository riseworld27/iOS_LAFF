//
//  FFTodayScreeningCell.h
//  laff
//
//  Created by matata on 2.05.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Screening.h"

extern NSString * const FFTodayScreeningCellIdentifier;
extern CGFloat const FFTodayScreeningCellHeight;

@interface FFTodayScreeningCell : UITableViewCell

@property (nonatomic, strong) Screening * screening;

@end
