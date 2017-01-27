//
//  FFEventScreeningCell.h
//  laff
//
//  Created by matata on 5.05.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Screening.h"

extern NSString * const FFEventScreeningCellIdentifier;
extern CGFloat const FFEventScreeningCellHeight;

@interface FFEventScreeningCell : UITableViewCell

- (void)updateWithScreening:(Screening *)screening highlighted:(BOOL)highlighted hasLocation:(BOOL)hasLocation;

@end
