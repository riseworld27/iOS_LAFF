//
//  FFPlayingScreeningsCell.h
//  laff
//
//  Created by matata on 17.03.15.
//  Copyright (c) 2015 matata. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Screening.h"

extern NSString * const FFPlayingScreeningCellIdentifier;
extern CGFloat const FFPlayingScreeningCellHeight;

@interface FFPlayingScreeningCell : UITableViewCell

- (void)updateWithScreening:(Screening *)screening;

@end
