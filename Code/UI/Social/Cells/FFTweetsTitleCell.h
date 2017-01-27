//
//  FFTweetsTitleCell.h
//  laff
//
//  Created by matata on 29.04.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const FFTweetsTitleCellIdentifier;
extern CGFloat const FFTweetsTitleCellHeight;

@interface FFTweetsTitleCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
